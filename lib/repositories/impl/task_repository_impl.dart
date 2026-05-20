import 'dart:io';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import '../task_repository.dart';
import '../../models/task_model.dart';
import '../../services/firebase_service.dart';
import '../../services/sqlite_service.dart';

class TaskRepositoryImpl implements TaskRepository {
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
  Future<List<Task>> getTasks() async {
    if (await _hasNetwork()) {
      try {
        final tasks = await _firebaseService.getAllTasks();
        for (var t in tasks) {
          await _sqliteService.cacheTask(t);
        }
        return tasks;
      } catch (e) {
        return _sqliteService.getAllLocalTasks();
      }
    } else {
      return _sqliteService.getAllLocalTasks();
    }
  }

  @override
  Future<List<Task>> getTasksByProject(String projectId) async {
    if (await _hasNetwork()) {
      try {
        final tasks = await _firebaseService.getTasksByProject(projectId);
        for (var t in tasks) {
          await _sqliteService.cacheTask(t);
        }
        return tasks;
      } catch (e) {
        return _sqliteService.getLocalTasksByProject(projectId);
      }
    } else {
      return _sqliteService.getLocalTasksByProject(projectId);
    }
  }

  @override
  Future<List<Task>> getTasksByUser(String userId) async {
    if (await _hasNetwork()) {
      try {
        final tasks = await _firebaseService.getTasksByUser(userId);
        for (var t in tasks) {
          await _sqliteService.cacheTask(t);
        }
        return tasks;
      } catch (e) {
        return _sqliteService.getLocalTasks(userId);
      }
    } else {
      return _sqliteService.getLocalTasks(userId);
    }
  }

  @override
  Future<void> addTask(Task task) async {
    if (await _hasNetwork()) {
      await _firebaseService.saveTask(task);
    }
    await _sqliteService.cacheTask(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    if (await _hasNetwork()) {
      await _firebaseService.saveTask(task);
    }
    await _sqliteService.cacheTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    // Để đơn giản, chỉ xử lý mềm hoặc không hỗ trợ delete offline hoàn toàn
    // Tạm thời bỏ qua delete ở local nếu phức tạp, hoặc chỉ thực thi khi online.
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics(String projectId) async {
    final tasks = await getTasksByProject(projectId);
    if (tasks.isEmpty) return {'total': 0, 'done': 0, 'progress': 0.0, 'todo': 0, 'doing': 0, 'reviewing': 0};

    int done = tasks.where((t) => t.status == 'done').length;
    int todo = tasks.where((t) => t.status == 'todo').length;
    int doing = tasks.where((t) => t.status == 'doing').length;
    int reviewing = tasks.where((t) => t.status == 'reviewing').length;
    double progress = (done / tasks.length) * 100;

    return {
      'total': tasks.length,
      'todo': todo,
      'doing': doing,
      'reviewing': reviewing,
      'done': done,
      'progress': progress,
    };
  }

  @override
  Future<Map<String, double>> getMemberStatistics() async {
    final tasks = await getTasks();
    final Map<String, double> stats = {};
    final userIds = tasks.map((t) => t.assignedTo).toSet();

    for (var userId in userIds) {
      final userTasks = tasks.where((t) => t.assignedTo == userId).toList();
      int done = userTasks.where((t) => t.status == 'done').length;
      stats[userId] = (done / userTasks.length) * 100;
    }

    return stats;
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final tasks = await getTasks();
    int todo = 0, doing = 0, reviewing = 0, done = 0;
    for (var t in tasks) {
      if (t.status == 'todo') todo++;
      else if (t.status == 'doing') doing++;
      else if (t.status == 'reviewing') reviewing++;
      else if (t.status == 'done') done++;
    }
    return {'todo': todo, 'doing': doing, 'reviewing': reviewing, 'done': done};
  }
}
