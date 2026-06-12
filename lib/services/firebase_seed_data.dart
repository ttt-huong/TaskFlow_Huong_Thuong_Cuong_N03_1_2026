import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'sqlite_service.dart';

/// ============================================================
/// Firebase Seed Data
/// Dùng để tạo dữ liệu ban đầu cho TaskFlow.
/// Sau khi seed xong, không gọi lại seedAll() trong app thật.
/// ============================================================
class FirebaseSeedData {
  static bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const String managerEmail = 'huong@gmail.com';
  static const String memberEmail = 'huong1@gmail.com';
  static const String memberEmail2 = 'huong2@gmail.com';
  static const String memberEmail3 = 'huong3@gmail.com';
  static const String defaultPassword = '123456';

  static Future<bool> seedAll() async {
    if (!_isFirebaseReady) {
      debugPrint('[SEED] Firebase chưa sẵn sàng.');
      return false;
    }

    try {
      debugPrint('[SEED] Đang làm sạch dữ liệu cũ...');
      await clearSeedData();

      debugPrint('[SEED] Bắt đầu tạo dữ liệu...');

      final managerId = await _seedUser(
        email: managerEmail,
        password: defaultPassword,
        name: 'Hường',
        role: 'manager',
      );

      final memberId = await _seedUser(
        email: memberEmail,
        password: defaultPassword,
        name: 'Duy',
        role: 'member',
      );

      final memberId2 = await _seedUser(
        email: memberEmail2,
        password: defaultPassword,
        name: 'Thương',
        role: 'member',
      );

      final memberId3 = await _seedUser(
        email: memberEmail3,
        password: defaultPassword,
        name: 'Cường',
        role: 'member',
      );

      await _auth.signInWithEmailAndPassword(
        email: managerEmail,
        password: defaultPassword,
      );

      final projectId = await _seedProject(
        name: 'Dự án Mobile App',
        description: 'Phát triển ứng dụng quản lý công việc TaskFlow bằng Flutter',
        memberIds: [managerId, memberId, memberId2, memberId3],
      );

      await _seedTask(
        title: 'Thiết kế giao diện đăng nhập',
        description: 'Xây dựng Login Screen theo Material Design 3',
        projectId: projectId,
        assignedTo: memberId,
        assigneeName: 'Duy',
        assigneeAvatar: 'D',
        status: 'todo',
        daysFromNow: 7,
      );

      await _seedTask(
        title: 'Tích hợp Firebase Authentication',
        description: 'Kết nối đăng nhập và đăng ký tài khoản',
        projectId: projectId,
        assignedTo: memberId,
        assigneeName: 'Duy',
        assigneeAvatar: 'D',
        status: 'doing',
        daysFromNow: 5,
      );

      await _seedTask(
        title: 'Kiểm thử luồng duyệt công việc',
        description: 'Member gửi task sang reviewing để Manager kiểm tra',
        projectId: projectId,
        assignedTo: memberId2,
        assigneeName: 'Thương',
        assigneeAvatar: 'T',
        status: 'reviewing',
        daysFromNow: 3,
      );

      await _seedTask(
        title: 'Thiết kế Database SQLite',
        description: 'Xây dựng schema local database version 7',
        projectId: projectId,
        assignedTo: memberId,
        assigneeName: 'Duy',
        assigneeAvatar: 'D',
        status: 'done',
        daysFromNow: 1,
      );

      await _seedTask(
        title: 'Tích hợp Notification Center',
        description: 'Thông báo phân công, từ chối và duyệt task',
        projectId: projectId,
        assignedTo: memberId3,
        assigneeName: 'Cường',
        assigneeAvatar: 'C',
        status: 'reviewing',
        daysFromNow: 2,
      );

      await _seedTask(
        title: 'Kiểm thử Offline Sync',
        description: 'Kiểm tra đồng bộ SQLite Local và Cloud Firestore',
        projectId: projectId,
        assignedTo: memberId2,
        assigneeName: 'Thương',
        assigneeAvatar: 'T',
        status: 'doing',
        daysFromNow: 4,
        isUrgent: true,
      );

      await _seedTask(
        title: 'Lập trình API Node.js',
        description: 'Xây dựng RESTful API cho TaskFlow backend',
        projectId: projectId,
        assignedTo: memberId3,
        assigneeName: 'Cường',
        assigneeAvatar: 'C',
        status: 'todo',
        daysFromNow: 6,
      );

      await _seedTask(
        title: 'Kiểm thử bảo mật',
        description: 'Đánh giá lỗ hổng bảo mật và phân quyền API',
        projectId: projectId,
        assignedTo: memberId2,
        assigneeName: 'Thương',
        assigneeAvatar: 'T',
        status: 'doing',
        daysFromNow: 8,
      );

      debugPrint('[SEED] Tạo dữ liệu thành công.');
      debugPrint('[SEED] Manager: $managerEmail / $defaultPassword');
      debugPrint('[SEED] Member 1: $memberEmail / $defaultPassword');
      debugPrint('[SEED] Member 2: $memberEmail2 / $defaultPassword');
      debugPrint('[SEED] Member 3: $memberEmail3 / $defaultPassword');

      return true;
    } catch (e) {
      debugPrint('[SEED] Lỗi tạo dữ liệu: $e');
      return false;
    }
  }

  static Future<bool> clearSeedData() async {
    if (!_isFirebaseReady) return false;

    try {
      final tasks = await _firestore.collection('tasks').get();
      for (final doc in tasks.docs) {
        await doc.reference.delete();
      }

      final projects = await _firestore.collection('projects').get();
      for (final doc in projects.docs) {
        await doc.reference.delete();
      }

      // Dọn dẹp cả SQLite local
      await SQLiteService().clearAllLocalData();

      debugPrint('[SEED] Đã xóa tasks và projects trên Firestore và SQLite local.');
      return true;
    } catch (e) {
      debugPrint('[SEED] Lỗi xóa dữ liệu: $e');
      return false;
    }
  }

  static Future<String> _seedUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    String uid;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      uid = credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = credential.user!.uid;
      } else {
        rethrow;
      }
    }

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'avatarChar': name.isNotEmpty ? name[0].toUpperCase() : 'U',
    });

    return uid;
  }

  static Future<String> _seedProject({
    required String name,
    required String description,
    required List<String> memberIds,
  }) async {
    final now = DateTime.now().toUtc();

    final docRef = await _firestore.collection('projects').add({
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  static Future<void> _seedTask({
    required String title,
    required String description,
    required String projectId,
    required String assignedTo,
    required String assigneeName,
    required String assigneeAvatar,
    required String status,
    required int daysFromNow,
    bool isUrgent = false,
  }) async {
    final now = DateTime.now().toUtc();
    final deadline = now.add(Duration(days: daysFromNow));

    await _firestore.collection('tasks').add({
      'title': title,
      'description': description,
      'projectId': projectId,
      'assignedTo': assignedTo,
      'assigneeName': assigneeName,
      'assigneeAvatar': assigneeAvatar,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'isUrgent': isUrgent,
      'updatedAt': now.toIso8601String(),
      'rejectionReason': '',
    });
  }
}
