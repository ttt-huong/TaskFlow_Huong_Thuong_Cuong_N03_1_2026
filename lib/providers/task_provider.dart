import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/impl/task_repository_impl.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedMemberFilter = '';
  String get selectedMemberFilter => _selectedMemberFilter;

  // ── Stats ──
  int get totalTasks => _tasks.length;
  int get todoCount => _tasks.where((t) => t.status == 'todo').length;
  int get doingCount => _tasks.where((t) => t.status == 'doing').length;
  int get reviewingCount => _tasks.where((t) => t.status == 'reviewing').length;
  int get doneCount => _tasks.where((t) => t.status == 'done').length;
  int get overdueCount => _tasks.where((t) => t.isOverdue()).length;

  // Thành viên làm nhiều task nhất
  String topAssignee(List members) {
    if (_tasks.isEmpty) return '';
    final Map<String, int> counts = {};
    for (var t in _tasks) {
      counts[t.assignedTo] = (counts[t.assignedTo] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // Thành viên hoàn thành tốt nhất
  String bestPerformer() {
    if (_tasks.isEmpty) return '';
    final Map<String, int> done = {};
    final Map<String, int> total = {};
    for (var t in _tasks) {
      total[t.assignedTo] = (total[t.assignedTo] ?? 0) + 1;
      if (t.status == 'done') {
        done[t.assignedTo] = (done[t.assignedTo] ?? 0) + 1;
      }
    }
    String best = '';
    double bestRate = -1;
    for (var uid in total.keys) {
      final rate = (done[uid] ?? 0) / total[uid]!;
      if (rate > bestRate) {
        bestRate = rate;
        best = uid;
      }
    }
    return best;
  }

  // Productivity score
  int productivityScore() {
    if (_tasks.isEmpty) return 0;
    return ((doneCount / totalTasks) * 100).round();
  }

  String productivityLabel() {
    final score = productivityScore();
    if (score <= 50) return 'Poor';
    if (score <= 75) return 'Good';
    return 'Excellent';
  }

  Color productivityColor() {
    final score = productivityScore();
    if (score <= 50) return const Color(0xFFEF4444);
    if (score <= 75) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Future<void> loadTasksByProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByProject(projectId);

    _isLoading = false;
    notifyListeners();
  }

  // Sửa đổi ở đây: Cho phép gọi hàm loadAllTasks() không cần truyền userId nếu giao diện gọi trống
  Future<void> loadAllTasks([String userId = '']) {
    return loadMyTasks(userId);
  }

  Future<void> loadMyTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  void setMemberFilter(String userId) {
    _selectedMemberFilter = userId;
    notifyListeners();
  }

  List<Task> filterByStatus(String status, {String? memberId}) {
    List<Task> result = List.from(_tasks);
    if (memberId != null && memberId.isNotEmpty) {
      result = result.where((t) => t.assignedTo == memberId).toList();
    }
    if (status != 'Tất cả') {
      result = result.where((t) {
        if (status == 'Review') return t.status.toLowerCase() == 'reviewing';
        return t.status.toLowerCase() == status.toLowerCase();
      }).toList();
    }
    return result;
  }

  List<Task> tasksForDay(DateTime day, {String? memberId}) {
    return _tasks.where((t) {
      final sameDay = t.deadline.year == day.year &&
          t.deadline.month == day.month &&
          t.deadline.day == day.day;
      if (memberId != null && memberId.isNotEmpty) {
        return sameDay && t.assignedTo == memberId;
      }
      return sameDay;
    }).toList();
  }

  Future<void> createTask(
    String title,
    String description,
    String projectId,
    String assignedTo,
    DateTime deadline, {
    String assigneeName = '',
    String assigneeAvatar = '',
    String priority = 'medium',
  }) async {
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
    );
    await _taskRepository.addTask(newTask);
    _tasks.add(newTask);
    notifyListeners();
  }

  // Đã sửa đổi ở đây: Thêm từ khóa await cho hàm bất đồng bộ updateStatus
  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      final updated = await task.updateStatus(newStatus);
      if (updated) {
        await _taskRepository.updateTask(task);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> updateTask(Task task) async {
    await _taskRepository.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _taskRepository.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<Map<String, dynamic>> getProjectStatistics(String projectId) async {
    return _taskRepository.getProjectStatistics(projectId);
  }

  Future<Map<String, double>> getMemberStatistics() async {
    return _taskRepository.getMemberStatistics();
  }
}
