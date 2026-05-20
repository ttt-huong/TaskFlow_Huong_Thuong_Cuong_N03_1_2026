import 'dart:io';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import '../project_repository.dart';
import '../../models/project_model.dart';
import '../../services/firebase_service.dart';
import '../../services/sqlite_service.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final SQLiteService _sqliteService = SQLiteService();

  Future<bool> _hasNetwork() async {
    if (Firebase.apps.isEmpty) return false;
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    if (await _hasNetwork()) {
      try {
        final projects = await _firebaseService.getProjects();
        for (var p in projects) {
          await _sqliteService.cacheProject(p);
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
    if (await _hasNetwork()) {
      await _firebaseService.saveProject(project);
    }
    await _sqliteService.cacheProject(project);
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    if (await _hasNetwork()) {
      await _firebaseService.saveProject(project);
    }
    await _sqliteService.cacheProject(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    // Để đơn giản, không xóa offline
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final projects = await getProjects();
    return {'total': projects.length};
  }
}
