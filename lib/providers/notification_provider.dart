import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../models/notification_model.dart';
import '../services/sqlite_service.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SQLiteService _sqliteService = SQLiteService();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool get _isOnline => ConnectivityService.instance.isOnline;
  
  List<NotificationModel> _notifications = [];

  String? _currentUserId;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _currentUserId = userId;
    
    if (_isOnline) {
      try {
        // Fetch from Firebase
        final serverNotifs = await _firebaseService.getNotificationsByUser(userId);
        // Cache to SQLite
        for (var n in serverNotifs) {
          await _sqliteService.cacheNotification(n);
        }
      } catch (e) {
        // ignore and fallback to local
      }
    }
    
    _notifications = await _sqliteService.getLocalNotifications(userId);
    if (_notifications.isEmpty) {
      await _seedMockNotifications(userId);
      _notifications = await _sqliteService.getLocalNotifications(userId);
    }
    notifyListeners();
  }

  void clearNotifications() {
    _currentUserId = null;
    _notifications = [];
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    // Chỉ cache nếu thông báo này dành cho user hiện tại (hoặc global)
    final notifToCache = notification.userId == null ? notification.copyWith(userId: _currentUserId) : notification;
    
    // Lưu vào SQLite
    await _sqliteService.cacheNotification(notifToCache);
    
    // Đẩy lên Firebase nếu có mạng
    if (_isOnline) {
      try {
        await _firebaseService.saveNotification(notifToCache);
      } catch (e) {
        // offline or fail -> keep local
      }
    }
    
    if (_currentUserId != null && (notifToCache.userId == _currentUserId || notifToCache.userId == null)) {
      _notifications.insert(0, notifToCache);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    await _sqliteService.markNotificationRead(id);
    if (_isOnline) {
      try {
        await _firebaseService.markNotificationRead(id);
      } catch (_) {}
    }
    
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

  Future<void> deleteNotificationsByTaskId(String taskId) async {
    await _sqliteService.deleteNotificationsByTaskId(taskId);
    if (_isOnline) {
      try {
        await _firebaseService.deleteNotificationsByTaskId(taskId);
      } catch (_) {}
    }
    
    _notifications.removeWhere((n) => n.relatedTaskId == taskId);
    notifyListeners();
  }

  Future<void> _seedMockNotifications(String userId) async {
    final mocks = [
      NotificationModel(
        id: '${userId}_n1',
        userId: userId,
        title: 'Chào mừng trở lại',
        message: 'Bạn có nhiệm vụ mới cần xử lý trong ngày hôm nay.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'task_assigned',
      ),
      NotificationModel(
        id: '${userId}_n2',
        userId: userId,
        title: 'Nhắc nhở công việc',
        message: 'Có một nhiệm vụ sắp đến hạn. Hãy kiểm tra ngay!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'reminder',
      ),
      NotificationModel(
        id: '${userId}_n3',
        userId: userId,
        title: 'Đồng bộ thành công',
        message: 'Dữ liệu của bạn đã được đồng bộ lên máy chủ.',
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
