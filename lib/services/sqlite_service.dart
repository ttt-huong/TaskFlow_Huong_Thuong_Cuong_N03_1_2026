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
          'CREATE TABLE tasks_local(id TEXT PRIMARY KEY, title TEXT, description TEXT, projectId TEXT, assignedTo TEXT, status TEXT, deadline TEXT, syncedAt TEXT)',
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
      },
      version: 2,
    );
    return _db!;
  }

  // --- Tasks ---
  Future<void> cacheTask(Task task) async {
    final database = await db;
    await database.insert(
      'tasks_local',
      {
        ...task.toMap(),
        'id': task.id,
        'syncedAt': DateTime.now().toIso8601String()
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
