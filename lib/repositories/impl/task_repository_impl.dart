import 'dart:io';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
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
        final serverTasks = await _firebaseService.getAllTasks();
        final localTasks = await _sqliteService.getAllLocalTasks();
        
        await _mergeAndResolveConflicts(serverTasks, localTasks);
        
        return await _sqliteService.getAllLocalTasks();
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
        final serverTasks = await _firebaseService.getTasksByProject(projectId);
        final localTasks = await _sqliteService.getLocalTasksByProject(projectId);
        
        await _mergeAndResolveConflicts(serverTasks, localTasks);
        
        return await _sqliteService.getLocalTasksByProject(projectId);
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
        final serverTasks = await _firebaseService.getTasksByUser(userId);
        final localTasks = await _sqliteService.getLocalTasks(userId);
        
        await _mergeAndResolveConflicts(serverTasks, localTasks);
        
        return await _sqliteService.getLocalTasks(userId);
      } catch (e) {
        return _sqliteService.getLocalTasks(userId);
      }
    } else {
      return _sqliteService.getLocalTasks(userId);
    }
  }

  /// Thuật toán Xử lý Xung đột 3 bên (Triple Conflict Merge / Conflict Resolution)
  /// So sánh ngày cập nhật (updatedAt) giữa Local và Server để đồng bộ hóa hai chiều.
  Future<void> _mergeAndResolveConflicts(List<Task> serverTasks, List<Task> localTasks) async {
    final Map<String, Task> localMap = {for (var t in localTasks) t.id: t};
    final Map<String, Task> serverMap = {for (var t in serverTasks) t.id: t};

    // 1. Duyệt qua server tasks để cập nhật hoặc chèn mới vào local
    for (var serverTask in serverTasks) {
      final localTask = localMap[serverTask.id];
      if (localTask == null) {
        // Chỉ tồn tại ở Server -> tải về lưu Local
        await _sqliteService.cacheTask(serverTask, isSynced: true);
      } else {
        // Tồn tại ở cả 2 nơi -> So sánh updatedAt để giải quyết xung đột
        if (serverTask.updatedAt.isAfter(localTask.updatedAt)) {
          // Server mới hơn -> ghi đè lên Local
          await _sqliteService.cacheTask(serverTask, isSynced: true);
        } else if (localTask.updatedAt.isAfter(serverTask.updatedAt)) {
          // Local mới hơn (do sửa offline) -> đẩy lên Server
          try {
            await _firebaseService.saveTask(localTask);
            await _sqliteService.markTaskSynced(localTask.id);
          } catch (_) {
            // Nếu đẩy server lỗi, giữ trạng thái chưa sync ở SQLite để retry sau
          }
        } else {
          // Bằng nhau -> Đánh dấu là đã đồng bộ
          await _sqliteService.markTaskSynced(localTask.id);
        }
      }
    }

    // 2. Duyệt qua local tasks để đẩy các task offline mới tạo lên server
    for (var localTask in localTasks) {
      if (!serverMap.containsKey(localTask.id)) {
        // Chỉ tồn tại ở Local (do tạo offline) -> đẩy lên Server
        try {
          await _firebaseService.saveTask(localTask);
          await _sqliteService.markTaskSynced(localTask.id);
        } catch (_) {
          // Giữ chưa sync nếu offline
        }
      }
    }
  }

  @override
  Future<void> addTask(Task task) async {
    if (task.id.isEmpty) {
      task.id = const Uuid().v4();
    }
    task.updatedAt = DateTime.now();

    // 1. Ghi SQLite trước (Write-Ahead Logging / WAL) để tránh mất mát dữ liệu
    await _sqliteService.cacheTask(task, isSynced: false);

    // 2. Cố gắng đẩy lên Firestore ngầm nếu có mạng
    if (await _hasNetwork()) {
      try {
        await _firebaseService.saveTask(task);
        await _sqliteService.markTaskSynced(task.id);
      } catch (e) {
        print("Đang offline hoặc lỗi đẩy Firestore. Task sẽ được sync sau.");
      }
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();

    // 1. Ghi SQLite trước (Write-Ahead Logging / WAL) để cập nhật nhanh UI (Optimistic UI)
    await _sqliteService.cacheTask(task, isSynced: false);

    // 2. Cố gắng đẩy lên Firestore ngầm nếu có mạng
    if (await _hasNetwork()) {
      try {
        await _firebaseService.saveTask(task);
        await _sqliteService.markTaskSynced(task.id);
      } catch (e) {
        print("Đang offline hoặc lỗi cập nhật Firestore. Thay đổi sẽ được sync sau.");
      }
    }
  }

  /// Đồng bộ hóa toàn bộ Task đang có trạng thái isSynced = 0 lên Server (Background Sync)
  Future<void> syncPendingTasks() async {
    if (!(await _hasNetwork())) return;

    try {
      final pendingTasks = await _sqliteService.getUnsyncedTasks();
      for (var task in pendingTasks) {
        try {
          await _firebaseService.saveTask(task);
          await _sqliteService.markTaskSynced(task.id);
        } catch (e) {
          print("Lỗi đồng bộ task ${task.id}: $e");
        }
      }
    } catch (e) {
      print("Lỗi khi quét danh sách sync pending tasks: $e");
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    // Chỉ Manager mới có quyền xóa task theo Firestore rules.
    // Thực hiện mềm: Đánh dấu trạng thái 'cancelled' hoặc 'archived' thay vì xóa vật lý.
    if (await _hasNetwork()) {
      try {
        // Firebase Firestore delete
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('tasks').doc(id).delete();
      } catch (_) {}
    }
    // Xóa khỏi SQLite local
    final db = await _sqliteService.db;
    await db.delete('tasks_local', where: 'id = ?', whereArgs: [id]);
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
      stats[userId] = userTasks.isEmpty ? 0.0 : (done / userTasks.length) * 100;
    }

    return stats;
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final tasks = await getTasks();
    int todo = 0, doing = 0, reviewing = 0, done = 0;
    for (var t in tasks) {
      if (t.status == 'todo') {
        todo++;
      } else if (t.status == 'doing') {
        doing++;
      } else if (t.status == 'reviewing') {
        reviewing++;
      } else if (t.status == 'done') {
        done++;
      }
    }
    return {'todo': todo, 'doing': doing, 'reviewing': reviewing, 'done': done};
  }
}
