import 'package:flutter/material.dart';
import 'generics/data_printer.dart';
import 'models/task_model.dart';
import 'models/list_task.dart';

void main() {
  // ====================================================
  // CÂU 2: Demo Generics Class – In ra dữ liệu đầu vào
  // ====================================================
  print('');
  print('╔══════════════════════════════════════════╗');
  print('║   CÂU 2: GENERICS CLASS (Tổng quát hóa) ║');
  print('╚══════════════════════════════════════════╝');

  // Generics với kiểu int
  var intPrinter = DataPrinter<int>(2025);
  intPrinter.printData();

  // Generics với kiểu String
  var stringPrinter = DataPrinter<String>('TaskFlow - Quản lý công việc');
  stringPrinter.printData();

  // Generics với kiểu double
  var doublePrinter = DataPrinter<double>(3.14159);
  doublePrinter.printData();

  // Generics với kiểu bool
  var boolPrinter = DataPrinter<bool>(true);
  boolPrinter.printData();

  // Generics với danh sách
  var listPrinter = DataListPrinter<String>(
    ['Nguyen Van A', 'Tran Thi B', 'Le Van C'],
  );
  listPrinter.printAllData();

  // ====================================================
  // CÂU 3: Demo Task + ListTask với CRUD
  // ====================================================
  print('');
  print('╔══════════════════════════════════════════╗');
  print('║   CÂU 3: TASK + LISTTASK (CRUD)          ║');
  print('╚══════════════════════════════════════════╝');

  // Khởi tạo ListTask
  ListTask listTask = ListTask();

  // --- CREATE: Tạo và thêm các task ---
  print('\n--- CREATE ---');
  listTask.create(Task(
    id: 'T001',
    title: 'Thiet ke UI Login',
    projectId: 'P001',
    assignedTo: 'U002',
    status: 'todo',
    deadline: '2026-05-01',
  ));

  listTask.create(Task(
    id: 'T002',
    title: 'Ket noi Firebase Auth',
    projectId: 'P001',
    assignedTo: 'U003',
    status: 'doing',
    deadline: '2026-05-10',
  ));

  listTask.create(Task(
    id: 'T003',
    title: 'Viet API Firestore',
    projectId: 'P001',
    assignedTo: 'U002',
    status: 'done',
    deadline: '2026-04-20',
  ));

  // --- READ: Đọc tất cả các bản ghi ---
  print('\n--- READ ALL ---');
  listTask.readAll();

  // --- EDIT: Sửa task có ID cụ thể ---
  print('\n--- EDIT ---');
  listTask.edit(
    'T001',
    title: 'Thiet ke UI Login (Updated)',
    status: 'doing',
  );

  // Thử sửa task không tồn tại
  listTask.edit('T999', title: 'Khong ton tai');

  // Demo: Không cho nhảy từ todo → done
  print('\n--- DEMO: Luồng trạng thái ---');
  listTask.create(Task(
    id: 'T004',
    title: 'Test luong trang thai',
    projectId: 'P001',
    assignedTo: 'U002',
    status: 'todo',
    deadline: '2026-06-01',
  ));
  // Thử nhảy trực tiếp todo → done (sẽ bị chặn)
  listTask.edit('T004', status: 'done');
  // Phải chuyển todo → doing trước
  listTask.edit('T004', status: 'doing');

  // --- READ: Đọc lại sau khi sửa ---
  print('\n--- READ ALL (sau khi sửa) ---');
  listTask.readAll();

  // --- THỐNG KÊ ---
  listTask.thongKe();

  // ====================================================
  // Chạy ứng dụng Flutter
  // ====================================================
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
  // Dữ liệu demo
  final ListTask _listTask = ListTask();

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _listTask.create(Task(
      id: 'T001',
      title: 'Thiết kế UI Login',
      projectId: 'P001',
      assignedTo: 'Trần Thị B',
      status: 'todo',
      deadline: '2026-05-01',
    ));
    _listTask.create(Task(
      id: 'T002',
      title: 'Kết nối Firebase Auth',
      projectId: 'P001',
      assignedTo: 'Lê Văn C',
      status: 'doing',
      deadline: '2026-05-10',
    ));
    _listTask.create(Task(
      id: 'T003',
      title: 'Viết API Firestore',
      projectId: 'P001',
      assignedTo: 'Trần Thị B',
      status: 'done',
      deadline: '2026-04-20',
    ));
  }

  // Màu theo trạng thái
  Color _statusColor(String status) {
    switch (status) {
      case 'todo':
        return const Color(0xFFE74C3C);
      case 'doing':
        return const Color(0xFFF39C12);
      case 'done':
        return const Color(0xFF27AE60);
      default:
        return Colors.grey;
    }
  }

  // Icon theo trạng thái
  IconData _statusIcon(String status) {
    switch (status) {
      case 'todo':
        return Icons.radio_button_unchecked;
      case 'doing':
        return Icons.timelapse;
      case 'done':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 TaskFlow'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _listTask.tasks.length,
        itemBuilder: (context, index) {
          final task = _listTask.tasks[index];
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
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  task.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
