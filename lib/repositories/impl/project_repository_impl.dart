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
        final serverProjects = await _firebaseService.getProjects();
        final localProjects = await _sqliteService.getLocalProjects();

        // Dọn dẹp local projects bị xóa trên server
        final serverIds = serverProjects.map((p) => p.id).toSet();
        for (var lp in localProjects) {
          if (lp.isSynced == 1 && !serverIds.contains(lp.id)) {
            await _sqliteService.deleteProject(lp.id);
          }
        }

        final updatedLocalProjects = await _sqliteService.getLocalProjects();
        final localMap = {for (var p in updatedLocalProjects) p.id: p};

        for (var p in serverProjects) {
          final localProject = localMap[p.id];
          if (localProject != null &&
              localProject.isSynced == 0 &&
              localProject.updatedAt.isAfter(p.updatedAt)) {
            // Giữ bản local mới hơn chưa sync, không ghi đè
          } else {
            await _sqliteService.cacheProject(p, isSynced: true);
          }
        }
        return await _sqliteService.getLocalProjects();
      } catch (e) {
        return _sqliteService.getLocalProjects();
      }
    } else {
      return _sqliteService.getLocalProjects();
    }
  }

  @override
  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    if (_isOnline) {
      try {
        final serverProjects = await _firebaseService.getProjectsByUser(userId);
        final localProjects = await _sqliteService.getLocalProjects();

        // Dọn dẹp local projects mà user này không còn thuộc về trên server nữa
        final serverIds = serverProjects.map((p) => p.id).toSet();
        for (var lp in localProjects) {
          if (lp.isSynced == 1 && lp.memberIds.contains(userId) && !serverIds.contains(lp.id)) {
            await _sqliteService.deleteProject(lp.id);
          }
        }

        final updatedLocalProjects = await _sqliteService.getLocalProjects();
        final localMap = {for (var p in updatedLocalProjects) p.id: p};

        for (var p in serverProjects) {
          final localProject = localMap[p.id];
          if (localProject != null &&
              localProject.isSynced == 0 &&
              localProject.updatedAt.isAfter(p.updatedAt)) {
            // Giữ bản local mới hơn chưa sync, không ghi đè
          } else {
            await _sqliteService.cacheProject(p, isSynced: true);
          }
        }
      } catch (e) {
        // Bỏ qua lỗi
      }
    }
    final localProjects = await _sqliteService.getLocalProjects();
    return localProjects.where((p) => p.memberIds.contains(userId)).toList();
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
    project.updatedAt = DateTime.now().toUtc();
    if (_isOnline) {
      try {
        await _firebaseService.saveProject(project);
        await _sqliteService.cacheProject(project, isSynced: true);
      } catch (e) {
        // Ghi Firebase thất bại -> fallback lưu SQLite với isSynced = 0 để đồng bộ sau
        await _sqliteService.cacheProject(project, isSynced: false);
      }
    } else {
      // Offline → lưu local với isSynced=0, chờ sync khi có mạng
      await _sqliteService.cacheProject(project, isSynced: false);
    }
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    project.updatedAt = DateTime.now().toUtc();
    if (_isOnline) {
      try {
        await _firebaseService.saveProject(project);
        await _sqliteService.cacheProject(project, isSynced: true);
      } catch (e) {
        // Ghi Firebase thất bại -> fallback lưu SQLite với isSynced = 0 để đồng bộ sau
        await _sqliteService.cacheProject(project, isSynced: false);
      }
    } else {
      // Offline → cập nhật local, đánh dấu chờ sync
      await _sqliteService.cacheProject(project, isSynced: false);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    if (!_isOnline) {
      throw Exception("Không thể xóa dự án khi ngoại tuyến.");
    }
    await _firebaseService.deleteProject(id);
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
