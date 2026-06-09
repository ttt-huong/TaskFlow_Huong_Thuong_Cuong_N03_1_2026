import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class FirebaseService {
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

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
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
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
      'updatedAt': DateTime.now().toIso8601String(),
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

  /// Lấy danh sách Projects mà user là thành viên
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

  /// Xóa toàn bộ documents trong một collection (dùng cho seed/reset data)
  Future<void> clearCollection(String collectionName) async {
    if (!_isFirebaseReady) return;
    final snapshot = await _firestore.collection(collectionName).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- Notifications ---
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    if (!_isFirebaseReady) return [];
    
    // Lấy thông báo cá nhân HOẶC broadcast (userId == null)
    // Firestore không hỗ trợ OR query trực tiếp trên 1 trường dễ dàng,
    // nên ta tải tất cả cá nhân và broadcast, hoặc lấy query cơ bản và mix.
    // Để đơn giản, giả sử tải thông báo đích danh và broadcast.
    final personalSnap = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
        
    final broadcastSnap = await _firestore
        .collection('notifications')
        .where('userId', isNull: true)
        .get();

    final List<NotificationModel> notifs = [];
    notifs.addAll(personalSnap.docs.map((doc) => NotificationModel.fromMap(doc.data())));
    notifs.addAll(broadcastSnap.docs.map((doc) => NotificationModel.fromMap(doc.data())));
    
    // Sort bằng Dart
    notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifs;
  }

  Future<void> saveNotification(NotificationModel notification) async {
    if (!_isFirebaseReady) return;
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<void> markNotificationRead(String notificationId) async {
    if (!_isFirebaseReady) return;
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': 1});
  }

  Future<void> deleteNotificationsByTaskId(String taskId) async {
    if (!_isFirebaseReady) return;
    final snapshot = await _firestore
        .collection('notifications')
        .where('relatedTaskId', isEqualTo: taskId)
        .get();
        
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
