import '../task_repository.dart';
import '../../models/task_model.dart';
import '../mocks/list_task.dart';

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
  Future<List<Task>> getTasksByProject(String projectId) async {
    return _listTask.tasks.where((t) => t.projectId == projectId).toList();
  }

  @override
  Future<List<Task>> getTasksByUser(String userId) async {
    return _listTask.tasks.where((t) => t.assignedTo == userId).toList();
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
  Future<Map<String, dynamic>> getProjectStatistics(String projectId) async {
    final projectTasks = _listTask.tasks.where((t) => t.projectId == projectId).toList();
    if (projectTasks.isEmpty) return {'total': 0, 'done': 0, 'progress': 0.0};

    int done = projectTasks.where((t) => t.status == 'done').length;
    int todo = projectTasks.where((t) => t.status == 'todo').length;
    int doing = projectTasks.where((t) => t.status == 'doing').length;
    int reviewing = projectTasks.where((t) => t.status == 'reviewing').length;
    double progress = (done / projectTasks.length) * 100;

    return {
      'total': projectTasks.length,
      'todo': todo,
      'doing': doing,
      'reviewing': reviewing,
      'done': done,
      'progress': progress,
    };
  }

  @override
  Future<Map<String, double>> getMemberStatistics() async {
    final Map<String, double> stats = {};
    final userIds = _listTask.tasks.map((t) => t.assignedTo).toSet();

    for (var userId in userIds) {
      final userTasks = _listTask.tasks.where((t) => t.assignedTo == userId).toList();
      int done = userTasks.where((t) => t.status == 'done').length;
      stats[userId] = (done / userTasks.length) * 100;
    }

    return stats;
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    return _listTask.thongKe;
  }
}
