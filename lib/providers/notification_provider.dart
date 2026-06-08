import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/sqlite_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SQLiteService _sqliteService = SQLiteService();
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    loadNotifications();
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
}
