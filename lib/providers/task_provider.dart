import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/impl/task_repository_impl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

import 'package:uuid/uuid.dart';

/// Provider quản lý trạng thái danh sách Task cho toàn app.
/// Hỗ trợ phân trang (Pagination) và tải dữ liệu theo project hoặc user.
class TaskProvider extends ChangeNotifier {
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();

  NotificationProvider? _notificationProvider;
  void updateNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Phân trang (Pagination) ──
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  static const int _pageSize = 20;

  /// Tải danh sách Task theo Project (toàn bộ, không phân trang với Firestore)
  Future<void> loadTasksByProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByProject(projectId);
    _hasMore = _tasks.length >= _pageSize;

    _isLoading = false;
    notifyListeners();
  }

  /// Tải danh sách Task theo User (Member xem task của mình)
  Future<void> loadMyTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByUser(userId);
    _hasMore = _tasks.length >= _pageSize;

    _isLoading = false;
    notifyListeners();
  }

  /// Getter tối ưu: Chỉ lấy tối đa _pageSize task gần nhất để hiển thị
  List<Task> get displayedTasks =>
      _tasks.length > _pageSize ? _tasks.sublist(0, _pageSize) : _tasks;

  /// Tạo Task mới
  Future<void> createTask(String title, String description, String projectId,
      String assignedTo, DateTime deadline, {String assigneeName = '', String assigneeAvatar = ''}) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      projectId: projectId,
      assignedTo: assignedTo,
      status: 'todo',
      deadline: deadline,
      assigneeName: assigneeName,
      assigneeAvatar: assigneeAvatar,
    );
    await _taskRepository.addTask(newTask);
    _tasks.add(newTask);
    notifyListeners();

    // Trigger Notification for Member
    if (_notificationProvider != null) {
      _notificationProvider!.addNotification(
        NotificationModel(
          id: const Uuid().v4(),
          userId: assignedTo,
          relatedTaskId: newTask.id,
          title: 'Giao việc mới',
          message: 'Bạn vừa được giao nhiệm vụ: "$title".',
          createdAt: DateTime.now(),
          type: 'task_assigned',
        ),
      );
    }
  }

  /// Tải toàn bộ tasks (dùng cho Manager)
  Future<void> loadAllTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasks();
    _hasMore = _tasks.length >= _pageSize;

    _isLoading = false;
    notifyListeners();
  }

  /// Xóa Task (Chỉ Manager)
  Future<void> deleteTask(String taskId) async {
    await _taskRepository.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    
    // Xóa các thông báo mồ côi liên quan đến Task này
    if (_notificationProvider != null) {
      await _notificationProvider!.deleteNotificationsByTaskId(taskId);
    }
    
    notifyListeners();
  }

  /// Đồng bộ background pending tasks
  Future<void> syncPending() async {
    await _taskRepository.syncPendingTasks();
  }

  /// Cập nhật trạng thái Task theo ma trận chuyển đổi hợp lệ
  /// Sử dụng await vì updateStatus bây giờ trả về `Future<bool>`
  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      // Kiểm tra tính hợp lệ trước khi gọi repository
      final validationError = Task.validateTransition(task.status, newStatus);
      if (validationError != null) return false;

      if (await task.updateStatus(newStatus)) {
        await _taskRepository.updateTask(task);
        notifyListeners();

        // Trigger Notification
        if (_notificationProvider != null) {
          String title = '';
          String message = '';
          String? notifyUserId; // null means broadcast to all (managers)

          if (newStatus == 'reviewing') {
            title = 'Yêu cầu phê duyệt';
            message = 'Nhiệm vụ "${task.title}" đã được nộp. Vui lòng kiểm tra.';
            notifyUserId = null; // Broadcast to managers
          } else if (newStatus == 'done') {
            title = 'Nhiệm vụ hoàn thành';
            message = 'Tuyệt vời! Nhiệm vụ "${task.title}" của bạn đã được phê duyệt.';
            notifyUserId = task.assignedTo;
          } else if (newStatus == 'doing' && task.status == 'reviewing') {
            title = 'Nhiệm vụ bị từ chối';
            message = 'Nhiệm vụ "${task.title}" cần sửa lại. Vui lòng xem nhận xét.';
            notifyUserId = task.assignedTo;
          }

          if (title.isNotEmpty) {
            _notificationProvider!.addNotification(NotificationModel(
              id: const Uuid().v4(),
              userId: notifyUserId,
              relatedTaskId: task.id,
              title: title,
              message: message,
              createdAt: DateTime.now(),
              type: 'status_update',
            ));
          }
        }
        return true;
      }
    }
    return false;
  }

  /// Lọc danh sách Task theo trạng thái
  List<Task> filterByStatus(String status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  /// Lọc danh sách Task quá hạn (Overdue)
  List<Task> get overdueTasks {
    return _tasks.where((t) => t.isOverdue()).toList();
  }
}
