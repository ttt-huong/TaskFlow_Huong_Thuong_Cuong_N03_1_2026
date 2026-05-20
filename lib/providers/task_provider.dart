import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/impl/task_repository_impl.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTasksByProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByProject(projectId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasksByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTask(String title, String description, String projectId, String assignedTo, DateTime deadline) async {
    final newTask = Task(
      id: '',
      title: title,
      description: description,
      projectId: projectId,
      assignedTo: assignedTo,
      status: 'todo',
      deadline: deadline,
    );
    await _taskRepository.addTask(newTask);
    _tasks.add(newTask);
    notifyListeners();
  }

  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      if (task.updateStatus(newStatus)) {
        await _taskRepository.updateTask(task);
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
