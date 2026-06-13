import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../repositories/impl/task_repository_impl.dart';

/// Provider quản lý trạng thái danh sách Task cho toàn app.
/// Hỗ trợ phân trang (Pagination) và tải dữ liệu theo project hoặc user.
class TaskProvider extends ChangeNotifier {
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Track the last loaded query parameters for automatic refresh on sync reconnect
  String? _lastProjectId;
  String? _lastUserId;
  bool _loadedAll = false;

  bool isHomeTaskScopeFor(UserModel user) {
    return user.isManager
        ? _loadedAll && _lastProjectId == null && _lastUserId == null
        : _lastUserId == user.id && _lastProjectId == null && !_loadedAll;
  }

  Future<void> loadHomeTasks(UserModel user) {
    return user.isManager ? loadAllTasks() : loadMyTasks(user.id);
  }

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
    _lastProjectId = projectId;
    _lastUserId = null;
    _loadedAll = false;
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByProject(projectId);
    _hasMore = _tasks.length >= _pageSize;

    _isLoading = false;
    notifyListeners();
  }

  /// Tải danh sách Task theo User (Member xem task của mình)
  Future<void> loadMyTasks(String userId) async {
    _lastProjectId = null;
    _lastUserId = userId;
    _loadedAll = false;
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
      String assignedTo, DateTime deadline,
      {String assigneeName = '',
      String assigneeAvatar = '',
      bool isUrgent = false}) async {
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
      _projectStats[projectId] =
          await _taskRepository.getProjectStatistics(projectId);
    }
    notifyListeners();
  }

  /// Chỉnh sửa/Gán lại Task (Chỉ Manager)
  Future<void> editTask(Task updatedTask) async {
    await _taskRepository.updateTask(updatedTask);
    _upsertTask(updatedTask);

    final projectId = updatedTask.projectId;
    // Cập nhật lại stats nếu đã có trong cache
    if (_projectStats.containsKey(projectId)) {
      _projectStats[projectId] =
          await _taskRepository.getProjectStatistics(projectId);
    }
    notifyListeners();
  }

  /// Tải toàn bộ tasks (dùng cho Manager)
  Future<void> loadAllTasks() async {
    _lastProjectId = null;
    _lastUserId = null;
    _loadedAll = true;
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
        _projectStats[projectId] =
            await _taskRepository.getProjectStatistics(projectId);
      }
      notifyListeners();
    }
  }

  /// Đồng bộ background pending tasks
  Future<void> syncPending() async {
    await _taskRepository.syncPendingTasks();
    if (_lastProjectId != null) {
      await loadTasksByProject(_lastProjectId!);
    } else if (_lastUserId != null) {
      await loadMyTasks(_lastUserId!);
    } else if (_loadedAll) {
      await loadAllTasks();
    }
  }

  /// Cập nhật trạng thái Task theo ma trận chuyển đổi hợp lệ
  /// Sử dụng await vì updateStatus bây giờ trả về `Future<bool>`
  Future<Task?> findTaskById(String taskId) async {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (_) {
      return _taskRepository.getTaskById(taskId);
    }
  }

  Future<Task?> _findMutableTaskById(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index >= 0) return _tasks[index];
    return _taskRepository.getTaskById(taskId);
  }

  void _upsertTask(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }

  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    final task = await _findMutableTaskById(taskId);
    if (task != null) {
      final projectId = task.projectId;
      // Kiểm tra tính hợp lệ trước khi gọi repository
      final validationError = Task.validateTransition(task.status, newStatus);
      if (validationError != null) return false;

      if (await task.updateStatus(newStatus)) {
        await _taskRepository.updateTask(task);
        _upsertTask(task);

        // Cập nhật lại stats nếu đã có trong cache
        if (_projectStats.containsKey(projectId)) {
          _projectStats[projectId] =
              await _taskRepository.getProjectStatistics(projectId);
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Phê duyệt nhiệm vụ (chuyển trạng thái từ reviewing -> done)
  Future<bool> approveTask(String taskId) async {
    final task = await _findMutableTaskById(taskId);
    if (task != null) {
      final projectId = task.projectId;
      final validationError = Task.validateTransition(task.status, 'done');
      if (validationError != null) return false;

      if (await task.updateStatus('done')) {
        task.rejectionReason = ''; // Reset lý do từ chối nếu được duyệt
        await _taskRepository.updateTask(task);
        _upsertTask(task);

        if (_projectStats.containsKey(projectId)) {
          _projectStats[projectId] =
              await _taskRepository.getProjectStatistics(projectId);
        }
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Từ chối nhiệm vụ (chuyển trạng thái từ reviewing -> todo kèm lý do)
  Future<bool> rejectTask(String taskId, String reason) async {
    final task = await _findMutableTaskById(taskId);
    if (task != null) {
      final projectId = task.projectId;
      final validationError = Task.validateTransition(task.status, 'todo');
      if (validationError != null) return false;

      if (await task.updateStatus('todo')) {
        task.rejectionReason = reason;
        await _taskRepository.updateTask(task);
        _upsertTask(task);

        if (_projectStats.containsKey(projectId)) {
          _projectStats[projectId] =
              await _taskRepository.getProjectStatistics(projectId);
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
