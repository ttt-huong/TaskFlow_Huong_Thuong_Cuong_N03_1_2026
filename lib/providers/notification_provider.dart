import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../services/sqlite_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SQLiteService _sqliteService = SQLiteService();
  List<NotificationModel> _notifications = [];
  UserModel? _currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSubscription;

  // Bản lưu trữ tasks từ snapshot trước để so sánh trạng thái và tìm thay đổi
  final Map<String, Task> _previousTasks = {};
  bool _isFirstSnapshot = true;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    loadNotifications();
  }

  void updateUser(UserModel? user) {
    if (_currentUser?.id == user?.id) return;
    _currentUser = user;
    _isFirstSnapshot = true;
    _previousTasks.clear();
    _tasksSubscription?.cancel();
    _tasksSubscription = null;

    if (user != null && Firebase.apps.isNotEmpty) {
      _startListeningToTasks();
    }
  }

  void _startListeningToTasks() {
    if (_currentUser == null) return;
    final firestore = FirebaseFirestore.instance;

    // Lắng nghe tất cả các thay đổi của Tasks trong Firestore
    _tasksSubscription = firestore.collection('tasks').snapshots().listen((snapshot) {
      if (_currentUser == null) return;

      final currentTasks = snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();

      if (_isFirstSnapshot) {
        // Snapshot đầu tiên: Chỉ lưu trữ trạng thái hiện tại, không bắn thông báo
        for (var task in currentTasks) {
          _previousTasks[task.id] = task;
        }
        _isFirstSnapshot = false;
        return;
      }

      for (var task in currentTasks) {
        final previousTask = _previousTasks[task.id];

        // 1. Kiểm tra luồng Member: Manager giao task cho Member
        if (_currentUser!.role == 'member') {
          if (task.assignedTo == _currentUser!.id) {
            // Task mới được giao hoặc task đổi sang được giao cho member này
            if (previousTask == null || previousTask.assignedTo != _currentUser!.id) {
              _triggerNotification(
                title: 'Nhiệm vụ mới được giao 📋',
                message: 'Bạn vừa được giao nhiệm vụ "${task.title}".',
                type: 'task_assigned',
              );
            }
          }
        }

        // 2. Kiểm tra luồng Manager: Member nộp task (chuyển sang 'reviewing')
        if (_currentUser!.role == 'manager') {
          if (task.status.toLowerCase() == 'reviewing') {
            // Chỉ thông báo nếu trạng thái trước đó KHÔNG PHẢI là reviewing
            if (previousTask == null || previousTask.status.toLowerCase() != 'reviewing') {
              _triggerNotification(
                title: 'Nhiệm vụ chờ duyệt 📤',
                message: 'Thành viên ${task.assigneeName.isNotEmpty ? task.assigneeName : "chưa rõ"} đã nộp nhiệm vụ "${task.title}" để phê duyệt.',
                type: 'task_assigned',
              );
            }
          }
        }

        // Cập nhật lại cache task trước đó
        _previousTasks[task.id] = task;
      }

      // Xử lý các task bị xóa khỏi Firestore để dọn dẹp cache
      final currentIds = currentTasks.map((t) => t.id).toSet();
      _previousTasks.removeWhere((id, _) => !currentIds.contains(id));
    }, onError: (e) {
      debugPrint('NotificationProvider Firebase Stream Error: $e');
    });
  }

  Future<void> _triggerNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
      type: type,
    );
    await addNotification(notification);
  }

  Future<void> loadNotifications() async {
    _notifications = await _sqliteService.getLocalNotifications();
    if (_notifications.isEmpty) {
      await _seedMockNotifications();
      _notifications = await _sqliteService.getLocalNotifications();
    }
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _sqliteService.cacheNotification(notification);
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _sqliteService.markNotificationRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _sqliteService.markAllNotificationsRead();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> _seedMockNotifications() async {
    final mocks = [
      NotificationModel(
        id: 'n1',
        title: 'Có nhiệm vụ mới',
        message: 'Bạn vừa được giao nhiệm vụ "Cập nhật tài liệu API".',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'task_assigned',
      ),
      NotificationModel(
        id: 'n2',
        title: 'Nhiệm vụ sắp đến hạn',
        message: 'Nhiệm vụ "Fix lỗi UI trang chủ" sắp đến hạn trong 2 giờ nữa.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'reminder',
      ),
      NotificationModel(
        id: 'n3',
        title: 'Cập nhật hệ thống',
        message: 'Ứng dụng đã được nâng cấp lên phiên bản 2.0.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'system',
      ),
    ];
    for (var n in mocks) {
      await _sqliteService.cacheNotification(n);
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
