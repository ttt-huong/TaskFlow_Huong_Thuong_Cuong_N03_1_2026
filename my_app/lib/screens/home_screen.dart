import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../repositories/impl/local_task_repository.dart';
import '../widgets/task_card.dart';

/// HomePage – Màn hình chính hiển thị danh sách Task
/// Đã tách ra khỏi main.dart để tuân thủ phân tách trách nhiệm
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sử dụng Interface thay vì Class cụ thể (Tính đa hình)
  final TaskRepository _taskRepository = LocalTaskRepository();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Thêm dữ liệu mẫu vào Repository
    await _taskRepository.addTask(Task(
      id: 'T001',
      title: 'Thiết kế UI Login',
      description: 'Thiết kế giao diện đăng nhập với Material Design',
      projectId: 'P001',
      assignedTo: 'Trần Thị B',
      status: 'todo',
      deadline: DateTime.parse('2026-05-01'),
    ));
    await _taskRepository.addTask(Task(
      id: 'T002',
      title: 'Kết nối Firebase Auth',
      description: 'Tích hợp Firebase Authentication cho đăng nhập/đăng ký',
      projectId: 'P001',
      assignedTo: 'Lê Văn C',
      status: 'doing',
      deadline: DateTime.parse('2026-05-10'),
    ));
    await _taskRepository.addTask(Task(
      id: 'T003',
      title: 'Viết API Firestore',
      description: 'Xây dựng service đọc/ghi dữ liệu Firestore',
      projectId: 'P001',
      assignedTo: 'Trần Thị B',
      status: 'done',
      deadline: DateTime.parse('2026-04-20'),
    ));

    // Lấy danh sách task để hiển thị
    _tasks = await _taskRepository.getTasks();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 TaskFlow Pro'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return TaskCard(task: _tasks[index]);
              },
            ),
    );
  }
}
