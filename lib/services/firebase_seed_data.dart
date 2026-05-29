import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart' as app_fs;

/// Utility class để tạo dữ liệu mẫu trên Firebase cho mục đích test.
/// CHỈ DÙNG TRONG MÔI TRƯỜNG DEVELOPMENT/TEST.
class FirebaseSeedData {
  static bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static final app_fs.FirebaseService _firebaseService = app_fs.FirebaseService();

  // ─── ID cố định cho dữ liệu mẫu ───
  static const String _managerEmail = 'manager@gmail.com';
  static const String _memberEmail = 'member@gmail.com';
  static const String _defaultPassword = '123456';

  /// Seed toàn bộ dữ liệu mẫu lên Firebase (Auth + Firestore)
  /// Trả về true nếu thành công, false nếu lỗi
  static Future<bool> seedAll() async {
    if (!_isFirebaseReady) {
      debugPrint('[SEED] Firebase chưa sẵn sàng. Không thể seed dữ liệu.');
      return false;
    }

    try {
      debugPrint('[SEED] ═══════════════════════════════════════');
      debugPrint('[SEED] Bắt đầu seed dữ liệu Firebase...');

      // Lưu lại user đang đăng nhập hiện tại để khôi phục sau
      final currentUser = _auth.currentUser;
      final currentEmail = currentUser?.email;

      // 1. Tạo tài khoản Manager trên Firebase Auth + Firestore
      final managerId = await _seedUser(
        email: _managerEmail,
        password: _defaultPassword,
        name: 'Quản lý Nguyễn',
        role: 'manager',
      );
      debugPrint('[SEED] ✅ Manager created: $managerId');

      final memberId = await _seedUser(
        email: _memberEmail,
        password: _defaultPassword,
        name: 'Thành viên Trần',
        role: 'member',
      );
      debugPrint('[SEED] ✅ Member created: $memberId');

      // Đăng nhập lại bằng Manager để có quyền tạo Project và Task
      await _auth.signInWithEmailAndPassword(
        email: _managerEmail,
        password: _defaultPassword,
      );
      debugPrint('[SEED] Đã chuyển sang Manager Auth để ghi dữ liệu...');

      // 3. Tạo dự án mẫu
      final project1Id = await _seedProject(
        name: 'Dự án Mobile App',
        description: 'Phát triển ứng dụng quản lý công việc TaskFlow trên Flutter',
        memberIds: [managerId, memberId],
      );
      debugPrint('[SEED] ✅ Project 1 created: $project1Id');

      final project2Id = await _seedProject(
        name: 'Dự án Website',
        description: 'Xây dựng trang web quản trị cho hệ thống TaskFlow',
        memberIds: [managerId, memberId],
      );
      debugPrint('[SEED] ✅ Project 2 created: $project2Id');

      // 4. Tạo Tasks mẫu cho Project 1
      await _seedTask(
        title: 'Thiết kế giao diện đăng nhập',
        description: 'Tạo UI Login Screen với Material Design 3',
        projectId: project1Id,
        assignedTo: memberId,
        assigneeName: 'Thành viên Trần',
        assigneeAvatar: 'T',
        status: 'done',
        daysFromNow: 7,
      );

      await _seedTask(
        title: 'Tích hợp Firebase Auth',
        description: 'Kết nối đăng nhập/đăng ký với Firebase Authentication',
        projectId: project1Id,
        assignedTo: memberId,
        assigneeName: 'Thành viên Trần',
        assigneeAvatar: 'T',
        status: 'reviewing',
        daysFromNow: 5,
      );

      await _seedTask(
        title: 'Xây dựng màn hình danh sách Task',
        description: 'Hiển thị danh sách Task theo Project với bộ lọc trạng thái',
        projectId: project1Id,
        assignedTo: memberId,
        assigneeName: 'Thành viên Trần',
        assigneeAvatar: 'T',
        status: 'doing',
        daysFromNow: 10,
      );

      await _seedTask(
        title: 'Viết Unit Test cho Task Model',
        description: 'Kiểm tra State Machine transitions và validation logic',
        projectId: project1Id,
        assignedTo: memberId,
        assigneeName: 'Thành viên Trần',
        assigneeAvatar: 'T',
        status: 'todo',
        daysFromNow: 14,
      );

      // 5. Tạo Tasks mẫu cho Project 2
      await _seedTask(
        title: 'Thiết kế wireframe trang Dashboard',
        description: 'Tạo mockup cho trang tổng quan quản trị',
        projectId: project2Id,
        assignedTo: memberId,
        assigneeName: 'Thành viên Trần',
        assigneeAvatar: 'T',
        status: 'doing',
        daysFromNow: 3,
        isUrgent: true,
      );

      await _seedTask(
        title: 'Cài đặt môi trường Next.js',
        description: 'Khởi tạo project Next.js với TypeScript và Tailwind CSS',
        projectId: project2Id,
        assignedTo: memberId,
        assigneeName: 'Thành viên Trần',
        assigneeAvatar: 'T',
        status: 'todo',
        daysFromNow: 7,
      );

      debugPrint('[SEED] ✅ Tạo 6 tasks mẫu thành công');

      // 6. Khôi phục lại phiên đăng nhập ban đầu
      if (currentEmail != null) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: currentEmail,
            password: _defaultPassword,
          );
          debugPrint('[SEED] ✅ Đã khôi phục phiên đăng nhập: $currentEmail');
        } catch (e) {
          debugPrint('[SEED] ⚠️ Không thể khôi phục phiên. Cần đăng nhập lại.');
        }
      }

      debugPrint('[SEED] ═══════════════════════════════════════');
      debugPrint('[SEED] 🎉 SEED HOÀN TẤT! Kiểm tra Firebase Console.');
      return true;
    } catch (e) {
      debugPrint('[SEED] ❌ Lỗi seed dữ liệu: $e');
      return false;
    }
  }

  /// Xóa toàn bộ dữ liệu test trên Firestore (Chỉ xóa Tasks và Projects, giữ lại Users)
  static Future<bool> clearAll() async {
    if (!_isFirebaseReady) return false;
    try {
      debugPrint('[SEED] Đang xóa dữ liệu Firestore...');
      
      // Phải là manager mới có quyền xóa
      try {
        await _auth.signInWithEmailAndPassword(
          email: _managerEmail,
          password: _defaultPassword,
        );
      } catch (e) {
        debugPrint('[SEED] Không thể đăng nhập manager, có thể bị lỗi permission: $e');
      }

      await _firebaseService.clearCollection('tasks');
      await _firebaseService.clearCollection('projects');
      // Không xóa users vì rules không cho phép xóa user khác
      debugPrint('[SEED] ✅ Đã xóa toàn bộ dữ liệu Firestore.');
      return true;
    } catch (e) {
      debugPrint('[SEED] ❌ Lỗi xóa dữ liệu: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Các phương thức hỗ trợ nội bộ (Private Helpers)
  // ═══════════════════════════════════════════════════════════

  /// Tạo hoặc cập nhật tài khoản user trên Firebase Auth + Firestore
  /// Trả về UID của user
  static Future<String> _seedUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    String uid;

    try {
      // Thử tạo tài khoản mới trên Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      uid = credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Tài khoản đã tồn tại → đăng nhập để lấy UID
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = credential.user!.uid;
      } else {
        rethrow;
      }
    }

    // Ghi/ghi đè thông tin user lên Firestore
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'avatarChar': name.isNotEmpty ? name[0].toUpperCase() : 'U',
    });

    return uid;
  }

  /// Tạo dự án mẫu trên Firestore, trả về document ID
  static Future<String> _seedProject({
    required String name,
    required String description,
    required List<String> memberIds,
  }) async {
    // Kiểm tra xem project cùng tên đã tồn tại chưa
    final existing = await _firestore
        .collection('projects')
        .where('name', isEqualTo: name)
        .get();

    if (existing.docs.isNotEmpty) {
      // Đã tồn tại → cập nhật lại thông tin
      final docId = existing.docs.first.id;
      await _firestore.collection('projects').doc(docId).set({
        'name': name,
        'description': description,
        'memberIds': memberIds,
        'todoCount': 0,
        'doingCount': 0,
        'doneCount': 0,
        'progress': 0.0,
      });
      return docId;
    }

    // Chưa tồn tại → tạo mới
    final docRef = await _firestore.collection('projects').add({
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'todoCount': 0,
      'doingCount': 0,
      'doneCount': 0,
      'progress': 0.0,
    });
    return docRef.id;
  }

  /// Tạo task mẫu trên Firestore
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
    final now = DateTime.now();
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
    });
  }
}
