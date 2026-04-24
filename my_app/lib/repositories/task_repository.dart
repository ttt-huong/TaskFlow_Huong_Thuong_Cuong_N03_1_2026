import '../models/task_model.dart';

/// Đây là lớp trừu tượng (Interface) định nghĩa các quy tắc.
/// Bất kỳ Repository nào xử lý Task đều phải tuân theo các hàm này.
abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<Map<String, int>> getStatistics();
}
