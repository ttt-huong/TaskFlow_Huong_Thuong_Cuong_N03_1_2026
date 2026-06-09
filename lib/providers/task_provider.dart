import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/impl/task_repository_impl.dart';

/// Provider quản lý trạng thái danh sách Task cho toàn app.
/// Hỗ trợ phân trang (Pagination) và tải dữ liệu theo project hoặc user.
class TaskProvider extends ChangeNotifier {
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Lưu trữ thống kê tiến độ từng dự án
  final Map<String, Map<String, dynamic>> _projectStats = {};
  Map<String, Map<String, dynamic>> get projectStats => _projectStats;

  // ── Phân trang (Pagination) ──
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  static const int _pageSize = 20;

  /// Tải thống kê cho danh sách các dự án
  Future<void> loadProjectStats(List<String> projectIds) async {
    for (var id in projectIds) {
      _projectStats[id] = await _taskRepository.getProjectStatistics(id);
    }
    notifyListeners();
  }

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
      String assignedTo, DateTime deadline, {String assigneeName = '', String assigneeAvatar = '', bool isUrgent = false}) async {
    final newTask = Task(
      id: '',
      title: title,
      description: description,
      projectId: projectId,
      assignedTo: assignedTo,
      status: 'todo',
      deadline: deadline,
      assigneeName: assigneeName,
      assigneeAvatar: assigneeAvatar,
      isUrgent: isUrgent,
    );
    await _taskRepository.addTask(newTask);
    _tasks.add(newTask);
    
    // Cập nhật lại stats nếu đã có trong cache
    if (_projectStats.containsKey(projectId)) {
      _projectStats[projectId] = await _taskRepository.getProjectStatistics(projectId);
    }
    notifyListeners();
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
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final projectId = _tasks[index].projectId;
      await _taskRepository.deleteTask(taskId);
      _tasks.removeAt(index);
      
      // Cập nhật lại stats nếu đã có trong cache
      if (_projectStats.containsKey(projectId)) {
        _projectStats[projectId] = await _taskRepository.getProjectStatistics(projectId);
      }
      notifyListeners();
    }
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
      final projectId = task.projectId;
      // Kiểm tra tính hợp lệ trước khi gọi repository
      final validationError = Task.validateTransition(task.status, newStatus);
      if (validationError != null) return false;

      if (await task.updateStatus(newStatus)) {
        await _taskRepository.updateTask(task);
        
        // Cập nhật lại stats nếu đã có trong cache
        if (_projectStats.containsKey(projectId)) {
          _projectStats[projectId] = await _taskRepository.getProjectStatistics(projectId);
        }
        notifyListeners();
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
