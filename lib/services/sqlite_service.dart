import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class SQLiteService {
  static Database? _db;

  Future<Database> get db async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite không hỗ trợ trên Web');
    }

    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'taskflow.db'),
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
          'isSynced INTEGER DEFAULT 1'
          ')',
        );

        await db.execute(
          'CREATE TABLE projects_local(id TEXT PRIMARY KEY, name TEXT, description TEXT, memberIds TEXT, syncedAt TEXT, isSynced INTEGER DEFAULT 1)',
        );

        await db.execute(
          'CREATE TABLE users_local(id TEXT PRIMARY KEY, name TEXT, email TEXT, role TEXT, password TEXT, avatarChar TEXT)',
        );
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
              'ALTER TABLE users_local ADD COLUMN avatarChar TEXT',
            );
          } catch (_) {}
        }

        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE tasks_local ADD COLUMN assigneeName TEXT',
            );
            await db.execute(
              'ALTER TABLE tasks_local ADD COLUMN assigneeAvatar TEXT',
            );
            await db.execute(
              'ALTER TABLE tasks_local ADD COLUMN isUrgent INTEGER DEFAULT 0',
            );
            await db.execute(
              'ALTER TABLE tasks_local ADD COLUMN updatedAt TEXT',
            );
            await db.execute(
              'ALTER TABLE tasks_local ADD COLUMN isSynced INTEGER DEFAULT 1',
            );
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
      },
      version: 5,
    );

    return _db!;
  }

  // --- Tasks ---
  Future<void> cacheTask(Task task, {bool isSynced = true}) async {
    if (kIsWeb) return;

    final database = await db;

    final projectCheck = await database.query(
      'projects_local',
      where: 'id = ?',
      whereArgs: [task.projectId],
    );

    final anyProjects = await database.query('projects_local', limit: 1);

    if (anyProjects.isNotEmpty && projectCheck.isEmpty) {
      throw Exception(
        "Dự án '${task.projectId}' không tồn tại! Không thể thêm nhiệm vụ.",
      );
    }

    final map = task.toMap();
    map['isUrgent'] = task.isUrgent ? 1 : 0;

    await database.insert('tasks_local', {
      ...map,
      'id': task.id,
      'syncedAt': DateTime.now().toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getLocalTasks(String userId) async {
    if (kIsWeb) return [];

    final database = await db;

    final maps = await database.query(
      'tasks_local',
      where: 'assignedTo = ?',
      whereArgs: [userId],
    );

    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<List<Task>> getLocalTasksByProject(String projectId) async {
    if (kIsWeb) return [];

    final database = await db;

    final maps = await database.query(
      'tasks_local',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );

    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<List<Task>> getAllLocalTasks() async {
    if (kIsWeb) return [];

    final database = await db;
    final maps = await database.query('tasks_local');

    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<List<Task>> getUnsyncedTasks() async {
    if (kIsWeb) return [];

    final database = await db;

    final maps = await database.query('tasks_local', where: 'isSynced = 0');

    return maps.map((m) => Task.fromMap(m, m['id'] as String)).toList();
  }

  Future<void> markTaskSynced(String taskId) async {
    if (kIsWeb) return;

    final database = await db;

    await database.update(
      'tasks_local',
      {'isSynced': 1, 'syncedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(String taskId) async {
    if (kIsWeb) return;

    final database = await db;

    await database.delete('tasks_local', where: 'id = ?', whereArgs: [taskId]);
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
        'syncedAt': DateTime.now().toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProjectModel>> getLocalProjects() async {
    if (kIsWeb) return [];

    final database = await db;
    final maps = await database.query('projects_local');

    return maps.map((m) {
      final data = Map<String, dynamic>.from(m);
      data['memberIds'] = (data['memberIds'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList();

      return ProjectModel.fromMap(data, m['id'] as String);
    }).toList();
  }

  Future<void> deleteProject(String projectId) async {
    if (kIsWeb) return;

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
        'syncedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  // --- Users ---
  Future<void> cacheUser(UserModel user) async {
    if (kIsWeb) return;

    final database = await db;

    await database.insert('users_local', {
      ...user.toMap(),
      'id': user.id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserModel>> getLocalUsers() async {
    if (kIsWeb) return [];

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

  Future<List<NotificationModel>> getLocalNotifications() async {
    final database = await db;
    final maps = await database.query('notifications_local', orderBy: 'createdAt DESC');
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

  Future<void> markAllNotificationsRead() async {
    final database = await db;
    await database.update(
      'notifications_local',
      {'isRead': 1},
    );
  }
}
