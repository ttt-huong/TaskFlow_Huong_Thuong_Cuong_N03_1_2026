import '../task_repository.dart';
import '../../models/task_model.dart';

/// Triển khai thực tế của TaskRepository sử dụng bộ nhớ tạm (In-memory).
/// Sau này bạn có thể tạo FirebaseTaskRepository kế thừa từ TaskRepository.
class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getTasks() async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    return {
      'todo': _tasks.where((t) => t.status == 'todo').length,
      'doing': _tasks.where((t) => t.status == 'doing').length,
      'done': _tasks.where((t) => t.status == 'done').length,
      'overdue': _tasks.where((t) => t.isOverdue()).length,
      'total': _tasks.length,
    };
  }
}
