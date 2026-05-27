import '../models/task_model.dart';

/// Đây là lớp trừu tượng (Interface) định nghĩa các quy tắc.
/// Bất kỳ Repository nào xử lý Task đều phải tuân theo các hàm này.
abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<List<Task>> getTasksByProject(String projectId);
  Future<List<Task>> getTasksByUser(String userId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<Map<String, dynamic>> getProjectStatistics(String projectId);
  Future<Map<String, double>> getMemberStatistics();
  Future<Map<String, int>> getStatistics();
}
