import '../project_repository.dart';
import '../../models/project_model.dart';
import '../../services/firebase_service.dart';
import '../../services/sqlite_service.dart';
import '../../services/connectivity_service.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final SQLiteService _sqliteService = SQLiteService();

  bool get _isOnline => ConnectivityService.instance.isOnline;

  @override
  Future<List<ProjectModel>> getProjects() async {
    if (_isOnline) {
      try {
        final projects = await _firebaseService.getProjects();
        for (var p in projects) {
          // Cache từ server → đánh dấu đã đồng bộ
          await _sqliteService.cacheProject(p, isSynced: true);
        }
        return projects;
      } catch (e) {
        return _sqliteService.getLocalProjects();
      }
    } else {
      return _sqliteService.getLocalProjects();
    }
  }

  @override
  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    final projects = await getProjects();
    return projects.where((p) => p.memberIds.contains(userId)).toList();
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final projects = await getProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    if (_isOnline) {
      await _firebaseService.saveProject(project);
      await _sqliteService.cacheProject(project, isSynced: true);
    } else {
      // Offline → lưu local với isSynced=0, chờ sync khi có mạng
      await _sqliteService.cacheProject(project, isSynced: false);
    }
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    if (_isOnline) {
      await _firebaseService.saveProject(project);
      await _sqliteService.cacheProject(project, isSynced: true);
    } else {
      // Offline → cập nhật local, đánh dấu chờ sync
      await _sqliteService.cacheProject(project, isSynced: false);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    if (_isOnline) {
      await _firebaseService.deleteProject(id);
    }
    await _sqliteService.deleteProject(id);
  }

  /// Đồng bộ các Project đang pending lên Firestore (Background Sync)
  Future<void> syncPendingProjects() async {
    if (!_isOnline) return;
    try {
      final pendingProjects = await _sqliteService.getUnsyncedProjects();
      for (var project in pendingProjects) {
        try {
          await _firebaseService.saveProject(project);
          await _sqliteService.markProjectSynced(project.id);
        } catch (_) {
          // Bỏ qua project lỗi, retry ở lần sau
        }
      }
    } catch (_) {}
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final projects = await getProjects();
    return {'total': projects.length};
  }
}
