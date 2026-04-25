import '../task_repository.dart';
import '../../models/task_model.dart';
import '../list_task.dart';

/// Triển khai thực tế của TaskRepository sử dụng ListTask (Câu 3).
/// Giải quyết trùng lặp: Repository sử dụng ListTask làm nguồn dữ liệu nội bộ,
/// thay vì tự quản lý `List<Task>` riêng.
/// Sau này bạn có thể tạo FirebaseTaskRepository kế thừa từ TaskRepository.
class LocalTaskRepository implements TaskRepository {
  final ListTask _listTask = ListTask();

  @override
  Future<List<Task>> getTasks() async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 300));
    return _listTask.tasks;
  }

  @override
  Future<void> addTask(Task task) async {
    _listTask.create(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    _listTask.edit(
      task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assignedTo: task.assignedTo,
      status: task.status,
      deadline: task.deadline,
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    _listTask.delete(id);
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    return _listTask.thongKe;
  }
}
