import 'package:flutter/material.dart';
import 'models/task_model.dart';
import 'repositories/task_repository.dart';
import 'repositories/impl/local_task_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2196F3),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

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
    // 1. Thêm dữ liệu mẫu vào Repository
    await _taskRepository.addTask(Task(
      id: 'T001',
      title: 'Thiết kế UI Login',
      projectId: 'P001',
      assignedTo: 'Trần Thị B',
      status: 'todo',
      deadline: '2026-05-01',
    ));
    await _taskRepository.addTask(Task(
      id: 'T002',
      title: 'Kết nối Firebase Auth',
      projectId: 'P001',
      assignedTo: 'Lê Văn C',
      status: 'doing',
      deadline: '2026-05-10',
    ));
    await _taskRepository.addTask(Task(
      id: 'T003',
      title: 'Viết API Firestore',
      projectId: 'P001',
      assignedTo: 'Trần Thị B',
      status: 'done',
      deadline: '2026-04-20',
    ));

    // 2. Lấy danh sách task để hiển thị
    _tasks = await _taskRepository.getTasks();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Màu theo trạng thái
  Color _statusColor(String status) {
    switch (status) {
      case 'todo': return const Color(0xFFE74C3C);
      case 'doing': return const Color(0xFFF39C12);
      case 'done': return const Color(0xFF27AE60);
      default: return Colors.grey;
    }
  }

  // Icon theo trạng thái
  IconData _statusIcon(String status) {
    switch (status) {
      case 'todo': return Icons.radio_button_unchecked;
      case 'doing': return Icons.timelapse;
      case 'done': return Icons.check_circle;
      default: return Icons.help;
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
              final task = _tasks[index];
              final isOverdue = task.isOverdue();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isOverdue
                      ? const BorderSide(color: Colors.red, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Icon(
                    _statusIcon(task.status),
                    color: _statusColor(task.status),
                    size: 32,
                  ),
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('👤 ${task.assignedTo}'),
                      Text('📅 Deadline: ${task.deadline}'),
                      if (isOverdue)
                        const Text(
                          '⚠ QUÁ HẠN!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      task.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _statusColor(task.status),
                  ),
                ),
              );
            },
          ),
    );
  }
}
