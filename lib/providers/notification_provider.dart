import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/notification_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/sqlite_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SQLiteService _sqliteService = SQLiteService();
  final Map<String, Task> _previousTasks = {};

  List<NotificationModel> _notifications = [];
  UserModel? _currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSubscription;
  bool _isFirstSnapshot = true;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    loadNotifications();
  }

  void updateUser(UserModel? user) {
    if (_currentUser?.id == user?.id) return;

    _currentUser = user;
    _notifications = [];
    _isFirstSnapshot = true;
    _previousTasks.clear();
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    notifyListeners();

    if (user == null) return;

    loadNotifications(user.id);
    if (Firebase.apps.isNotEmpty) {
      _startListeningToTasks();
    }
  }

  void _startListeningToTasks() {
    final user = _currentUser;
    if (user == null) return;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('tasks');
    if (user.role != 'manager') {
      query = query.where('assignedTo', isEqualTo: user.id);
    }

    _tasksSubscription = query.snapshots().listen((snapshot) async {
      final currentUser = _currentUser;
      if (currentUser == null) return;

      final currentTasks = snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();

      if (_isFirstSnapshot) {
        for (final task in currentTasks) {
          _previousTasks[task.id] = task;
        }
        _isFirstSnapshot = false;
        return;
      }

      final currentIds = currentTasks.map((task) => task.id).toSet();
      final deletedIds =
          _previousTasks.keys.where((id) => !currentIds.contains(id)).toList();
      for (final id in deletedIds) {
        await deleteNotificationsByTaskId(id);
      }

      for (final task in currentTasks) {
        final previousTask = _previousTasks[task.id];
        await _handleTaskChangeForUser(currentUser, task, previousTask);
        _previousTasks[task.id] = task;
      }

      _previousTasks.removeWhere((id, _) => !currentIds.contains(id));
    }, onError: (error) {
      debugPrint('NotificationProvider Firebase Stream Error: $error');
    });
  }

  Future<void> _handleTaskChangeForUser(
    UserModel user,
    Task task,
    Task? previousTask,
  ) async {
    final status = task.status.toLowerCase();
    final previousStatus = previousTask?.status.toLowerCase();

    if (user.role == 'member' && task.assignedTo == user.id) {
      if (previousTask == null || previousTask.assignedTo != user.id) {
        await _triggerNotification(
          userId: user.id,
          relatedTaskId: task.id,
          title: 'Nhiệm vụ mới được giao',
          message: 'Bạn vừa được giao nhiệm vụ "${task.title}".',
          type: 'task_assigned',
          eventTime: task.updatedAt,
        );
      } else if (status == 'todo' && previousStatus == 'reviewing') {
        final reason = task.rejectionReason.trim();
        await _triggerNotification(
          userId: user.id,
          relatedTaskId: task.id,
          title: 'Nhiệm vụ bị từ chối',
          message: reason.isEmpty
              ? 'Nhiệm vụ "${task.title}" bị từ chối.'
              : 'Nhiệm vụ "${task.title}" bị từ chối. Lý do: "$reason".',
          type: 'task_rejected',
          eventTime: task.updatedAt,
        );
      } else if (status == 'done' && previousStatus == 'reviewing') {
        await _triggerNotification(
          userId: user.id,
          relatedTaskId: task.id,
          title: 'Nhiệm vụ được duyệt',
          message: 'Nhiệm vụ "${task.title}" của bạn đã được duyệt.',
          type: 'task_approved',
          eventTime: task.updatedAt,
        );
      }
    }

    if (user.role == 'manager' &&
        status == 'reviewing' &&
        previousStatus != 'reviewing') {
      await _triggerNotification(
        userId: user.id,
        relatedTaskId: task.id,
        title: 'Nhiệm vụ chờ duyệt',
        message:
            'Thành viên ${task.assigneeName.isNotEmpty ? task.assigneeName : "chưa rõ"} đã nộp nhiệm vụ "${task.title}" để phê duyệt.',
        type: 'task_review_submitted',
        eventTime: task.updatedAt,
      );
    }
  }

  Future<void> _triggerNotification({
    required String userId,
    required String? relatedTaskId,
    required String title,
    required String message,
    required String type,
    required DateTime eventTime,
  }) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      userId: userId,
      relatedTaskId: relatedTaskId,
      title: title,
      message: message,
      createdAt: eventTime.toUtc(),
      isRead: false,
      type: type,
    );
    await addNotification(notification);
  }

  Future<void> loadNotifications([String? userId]) async {
    final uid = userId ?? _currentUser?.id;
    if (uid == null || uid.isEmpty) {
      _notifications = [];
      notifyListeners();
      return;
    }

    _notifications = await _sqliteService.getLocalNotifications(uid);
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    final relatedTaskId = notification.relatedTaskId;
    if (relatedTaskId != null && relatedTaskId.isNotEmpty) {
      final existsInMemory = _notifications.any((n) =>
          n.userId == notification.userId &&
          n.relatedTaskId == relatedTaskId &&
          n.type == notification.type);
      if (existsInMemory) return;

      final existsInLocal = await _sqliteService.hasNotificationForTaskType(
        userId: notification.userId,
        relatedTaskId: relatedTaskId,
        type: notification.type,
      );
      if (existsInLocal) return;
    }

    await _sqliteService.cacheNotification(notification);
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _sqliteService.markNotificationRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final uid = _currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      await _sqliteService.markAllNotificationsRead(uid);
    }
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> deleteNotificationsByTaskId(String taskId) async {
    await _sqliteService.deleteNotificationsByTaskId(taskId);
    _notifications.removeWhere((n) => n.relatedTaskId == taskId);
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
