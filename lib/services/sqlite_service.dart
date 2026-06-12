import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class SQLiteService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'taskflow.db'),
      // Bật ràng buộc khóa ngoại để tránh dữ liệu mồ côi (Orphan Data)
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, v) async {
        await db.execute(
          'CREATE TABLE tasks_local('
          'id TEXT PRIMARY KEY, '
          'title TEXT, '
          'description TEXT, '
          'projectId TEXT REFERENCES projects_local(id) ON DELETE CASCADE, '
          'assignedTo TEXT, '
          'status TEXT, '
          'deadline TEXT, '
          'syncedAt TEXT, '
          'assigneeName TEXT, '
          'assigneeAvatar TEXT, '
          'isUrgent INTEGER DEFAULT 0, '
          'updatedAt TEXT, '
          'isSynced INTEGER DEFAULT 1, '
          'rejectionReason TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE projects_local(id TEXT PRIMARY KEY, name TEXT, description TEXT, memberIds TEXT, syncedAt TEXT, isSynced INTEGER DEFAULT 1, updatedAt TEXT)',
        );
        await db.execute(
          'CREATE TABLE users_local(id TEXT PRIMARY KEY, name TEXT, email TEXT, role TEXT, offlineAuthHash TEXT, avatarChar TEXT)',
        );
        await db.execute(
          'CREATE TABLE notifications_local('
          'id TEXT PRIMARY KEY, '
          'userId TEXT, '
          'relatedTaskId TEXT, '
          'title TEXT, '
          'message TEXT, '
          'createdAt TEXT, '
          'isRead INTEGER DEFAULT 0, '
          'type TEXT'
          ')',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE users_local ADD COLUMN avatarChar TEXT');
          } catch (_) {}
        }
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE tasks_local ADD COLUMN assigneeName TEXT');
            await db.execute('ALTER TABLE tasks_local ADD COLUMN assigneeAvatar TEXT');
            await db.execute('ALTER TABLE tasks_local ADD COLUMN isUrgent INTEGER DEFAULT 0');
            await db.execute('ALTER TABLE tasks_local ADD COLUMN updatedAt TEXT');
            await db.execute('ALTER TABLE tasks_local ADD COLUMN isSynced INTEGER DEFAULT 1');
          } catch (_) {}
        }
        if (oldVersion < 4) {
          try {
            // Thêm cột isSynced cho projects_local để queue offline projects
            await db.execute('ALTER TABLE projects_local ADD COLUMN isSynced INTEGER DEFAULT 1');
          } catch (_) {}
        }
        if (oldVersion < 5) {
          try {
            await db.execute(
              'CREATE TABLE notifications_local('
              'id TEXT PRIMARY KEY, '
              'title TEXT, '
              'message TEXT, '
              'createdAt TEXT, '
              'isRead INTEGER DEFAULT 0, '
              'type TEXT'
              ')',
            );
          } catch (_) {}
        }
        if (oldVersion < 6) {
          try {
            await db.execute('ALTER TABLE notifications_local ADD COLUMN userId TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE notifications_local ADD COLUMN relatedTaskId TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE tasks_local ADD COLUMN rejectionReason TEXT');
          } catch (_) {}
        }
        if (oldVersion < 7) {
          try {
            await db.execute('ALTER TABLE users_local RENAME COLUMN password TO offlineAuthHash');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE projects_local ADD COLUMN updatedAt TEXT');
          } catch (_) {}
        }
      },
      version: 7,
    );
    return _db!;
  }

  // --- Tasks ---
  Future<void> cacheTask(Task task, {bool isSynced = true}) async {
    final database = await db;
    // Kiểm tra xem Project cha có tồn tại không để tránh dữ liệu mồ côi (Orphan Data)
    final projectCheck = await database.query(
      'projects_local',
      where: 'id = ?',
      whereArgs: [task.projectId],
    );
    final anyProjects = await database.query('projects_local', limit: 1);
    if (anyProjects.isNotEmpty && projectCheck.isEmpty) {
      throw Exception("Dự án '${task.projectId}' không tồn tại! Không thể thêm nhiệm vụ.");
    }
    
    final map = task.toMap();
    // Chuyển đổi boolean sang integer cho SQLite
    map['isUrgent'] = task.isUrgent ? 1 : 0;
    
    await database.insert(
      'tasks_local',
      {
        ...map,
        'id': task.id,
        'syncedAt': DateTime.now().toUtc().toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getLocalTasks(String userId) async {
    final database = await db;
    final maps = await database.query(
      'tasks_local',
      where: 'assignedTo = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<List<Task>> getLocalTasksByProject(String projectId) async {
    final database = await db;
    final maps = await database.query(
      'tasks_local',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<List<Task>> getAllLocalTasks() async {
    final database = await db;
    final maps = await database.query('tasks_local');
    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<Task?> getLocalTaskById(String taskId) async {
    final database = await db;
    final maps = await database.query(
      'tasks_local',
      where: 'id = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first, maps.first['id'] as String);
  }

  Future<List<Task>> getUnsyncedTasks() async {
    final database = await db;
    final maps = await database.query(
      'tasks_local',
      where: 'isSynced = 0',
    );
    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<void> markTaskSynced(String taskId) async {
    final database = await db;
    await database.update(
      'tasks_local',
      {
        'isSynced': 1,
        'syncedAt': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final database = await db;
    await database.delete(
      'tasks_local',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // --- Projects ---
  Future<void> cacheProject(ProjectModel project, {bool isSynced = true}) async {
    final database = await db;
    await database.insert(
      'projects_local',
      {
        'id': project.id,
        'name': project.name,
        'description': project.description,
        'memberIds': project.memberIds.join(','),
        'syncedAt': DateTime.now().toUtc().toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': project.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProjectModel>> getLocalProjects() async {
    final database = await db;
    final maps = await database.query('projects_local');
    return maps.map((m) {
      final data = Map<String, dynamic>.from(m);
      data['memberIds'] = (data['memberIds'] as String).split(',').where((e) => e.isNotEmpty).toList();
      return ProjectModel.fromMap(data, m['id'] as String);
    }).toList();
  }

  Future<void> deleteProject(String projectId) async {
    final database = await db;
    await database.delete(
      'projects_local',
      where: 'id = ?',
      whereArgs: [projectId],
    );
    await database.delete(
      'tasks_local',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
  }

  Future<List<ProjectModel>> getUnsyncedProjects() async {
    final database = await db;
    final maps = await database.query(
      'projects_local',
      where: 'isSynced = 0',
    );
    return maps.map((m) {
      final data = Map<String, dynamic>.from(m);
      data['memberIds'] = (data['memberIds'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList();
      return ProjectModel.fromMap(data, m['id'] as String);
    }).toList();
  }

  Future<void> markProjectSynced(String projectId) async {
    final database = await db;
    await database.update(
      'projects_local',
      {
        'isSynced': 1,
        'syncedAt': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  // --- Users ---
  Future<void> cacheUser(UserModel user) async {
    final database = await db;
    await database.insert(
      'users_local',
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'offlineAuthHash': user.password,
        'avatarChar': user.avatarChar,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserModel>> getLocalUsers() async {
    final database = await db;
    final maps = await database.query('users_local');
    return maps.map((m) => UserModel.fromMap(m, m['id'] as String)).toList();
  }

  // --- Notifications ---
  Future<void> cacheNotification(NotificationModel notification) async {
    final database = await db;
    await database.insert(
      'notifications_local',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> hasNotificationForTaskType({
    required String userId,
    required String relatedTaskId,
    required String type,
  }) async {
    final database = await db;
    final maps = await database.query(
      'notifications_local',
      columns: ['id'],
      where: 'userId = ? AND relatedTaskId = ? AND type = ?',
      whereArgs: [userId, relatedTaskId, type],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<NotificationModel>> getLocalNotifications(String userId) async {
    final database = await db;
    final maps = await database.query(
      'notifications_local',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<void> markNotificationRead(String id) async {
    final database = await db;
    await database.update(
      'notifications_local',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final database = await db;
    await database.update(
      'notifications_local',
      {'isRead': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteNotificationsByTaskId(String taskId) async {
    final database = await db;
    await database.delete(
      'notifications_local',
      where: 'relatedTaskId = ?',
      whereArgs: [taskId],
    );
  }

  // --- User profile updates ---
  Future<void> updateUserName(String userId, String newName) async {
    final database = await db;
    await database.update(
      'users_local',
      {'name': newName, 'avatarChar': newName.isNotEmpty ? newName[0].toUpperCase() : 'U'},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserPassword(String userId, String newPassword) async {
    final database = await db;
    await database.update(
      'users_local',
      {'offlineAuthHash': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAllLocalData() async {
    final database = await db;
    await database.delete('tasks_local');
    await database.delete('projects_local');
    await database.delete('notifications_local');
  }
}
