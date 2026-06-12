import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<bool> _isCurrentUserManager() async {
    if (!_isFirebaseReady) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    if (user.email == 'huong@gmail.com') return true;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists && doc.data()?['role'] == 'manager';
    } catch (_) {
      return false;
    }
  }

  // --- Users ---
  Future<List<UserModel>> getUsers() async {
    if (!_isFirebaseReady) return [];
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<UserModel?> getUserById(String id) async {
    if (!_isFirebaseReady) return null;
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    if (!_isFirebaseReady) return;
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // --- Projects ---
  Future<List<ProjectModel>> getProjects() async {
    if (!_isFirebaseReady) return [];
    if (!await _isCurrentUserManager()) {
      throw Exception("Quyền truy cập bị từ chối: Chỉ quản lý mới có quyền xem toàn bộ dự án.");
    }
    final snapshot = await _firestore.collection('projects').get();
    return snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveProject(ProjectModel project) async {
    if (!_isFirebaseReady) return;
    final docRef = _firestore.collection('projects').doc(project.id.isEmpty ? null : project.id);
    if (project.id.isEmpty) {
      project.id = docRef.id;
    }
    await docRef.set(project.toMap());
  }

  // --- Tasks ---
  Future<List<Task>> getTasksByProject(String projectId) async {
    if (!_isFirebaseReady) return [];
    final snapshot = await _firestore.collection('tasks').where('projectId', isEqualTo: projectId).get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    if (!_isFirebaseReady) return [];
    final snapshot = await _firestore.collection('tasks').where('assignedTo', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
  }
  
  Future<List<Task>> getAllTasks() async {
    if (!_isFirebaseReady) return [];
    if (!await _isCurrentUserManager()) {
      throw Exception("Quyền truy cập bị từ chối: Chỉ quản lý mới có quyền xem toàn bộ nhiệm vụ.");
    }
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Task?> getTaskById(String taskId) async {
    if (!_isFirebaseReady) return null;
    final doc = await _firestore.collection('tasks').doc(taskId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Task.fromMap(doc.data()!, doc.id);
  }

  Future<void> saveTask(Task task) async {
    if (!_isFirebaseReady) return;
    final docRef = _firestore.collection('tasks').doc(task.id.isEmpty ? null : task.id);
    if (task.id.isEmpty) {
      task.id = docRef.id;
    }
    await docRef.set(task.toMap());
  }
  
  /// Cập nhật trạng thái Task - gửi kèm updatedAt để khớp Firestore rules
  /// (hasOnly(['status', 'updatedAt']))
  Future<void> updateTaskStatus(String taskId, String status) async {
    if (!_isFirebaseReady) return;
    await _firestore.collection('tasks').doc(taskId).update({
      'status': status,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Xóa một Task khỏi Firestore (Chỉ Manager mới có quyền)
  Future<void> deleteTask(String taskId) async {
    if (!_isFirebaseReady) return;
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  /// Xóa một Project khỏi Firestore (Chỉ Manager mới có quyền)
  Future<void> deleteProject(String projectId) async {
    if (!_isFirebaseReady) return;
    await _firestore.collection('projects').doc(projectId).delete();
  }

  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    if (!_isFirebaseReady) return [];
    final snapshot = await _firestore
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .get();
    return snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
