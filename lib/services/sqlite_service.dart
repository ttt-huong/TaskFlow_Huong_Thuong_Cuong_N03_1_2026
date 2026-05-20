import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class SQLiteService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'taskflow.db'),
      onCreate: (db, v) async {
        await db.execute(
          'CREATE TABLE tasks_local('
          'id TEXT PRIMARY KEY, '
          'title TEXT, '
          'description TEXT, '
          'projectId TEXT, '
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
          'CREATE TABLE projects_local(id TEXT PRIMARY KEY, name TEXT, description TEXT, memberIds TEXT, syncedAt TEXT)',
        );
        await db.execute(
          'CREATE TABLE users_local(id TEXT PRIMARY KEY, name TEXT, email TEXT, role TEXT, password TEXT, avatarChar TEXT)',
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
      },
      version: 3,
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
        'syncedAt': DateTime.now().toIso8601String(),
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
        'syncedAt': DateTime.now().toIso8601String(),
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
  Future<void> cacheProject(ProjectModel project) async {
    final database = await db;
    await database.insert(
      'projects_local',
      {
        'id': project.id,
        'name': project.name,
        'description': project.description,
        'memberIds': project.memberIds.join(','),
        'syncedAt': DateTime.now().toIso8601String()
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
    // Also delete tasks associated with this project
    await database.delete(
      'tasks_local',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
  }

  // --- Users ---
  Future<void> cacheUser(UserModel user) async {
    final database = await db;
    await database.insert(
      'users_local',
      {
        ...user.toMap(),
        'id': user.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserModel>> getLocalUsers() async {
    final database = await db;
    final maps = await database.query('users_local');
    return maps.map((m) => UserModel.fromMap(m, m['id'] as String)).toList();
  }
}
