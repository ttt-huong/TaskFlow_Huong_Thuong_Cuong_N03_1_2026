import 'generics/data_printer.dart';
import 'models/task_model.dart';
import 'repositories/list_task.dart';

/// Hàm chạy các demo logic console (Câu 2, Câu 3)
/// Tách ra khỏi main.dart để code sạch sẽ hơn.
void runConsoleDemos() {
  // ====================================================
  // CÂU 2: Demo Generics Class
  // ====================================================
  print('\n--- CÂU 2: GENERICS CLASS ---');
  DataPrinter<int>(2025).printData();
  DataPrinter<String>('TaskFlow - Quản lý công việc').printData();
  DataListPrinter<String>(['Nguyen Van A', 'Tran Thi B', 'Le Van C']).printAllData();

  // ====================================================
  // CÂU 3: Demo Task + ListTask với CRUD
  // ====================================================
  print('\n--- CÂU 3: TASK + LISTTASK (CRUD) ---');
  ListTask listTask = ListTask();

  // CREATE
  listTask.create(Task(
    id: 'T001',
    title: 'Thiet ke UI Login',
    description: 'Thiet ke giao dien dang nhap',
    projectId: 'P001',
    assignedTo: 'U002',
    status: 'todo',
    deadline: DateTime.parse('2026-05-01'),
  ));

  listTask.create(Task(
    id: 'T002',
    title: 'Ket noi Firebase Auth',
    description: 'Tich hop Firebase Authentication',
    projectId: 'P001',
    assignedTo: 'U003',
    status: 'doing',
    deadline: DateTime.parse('2026-05-10'),
  ));

  // READ
  print('\nDanh sách task hiện tại:');
  listTask.tasks.forEach(print);

  // EDIT
  listTask.edit('T001', title: 'Thiet ke UI Login (Updated)', status: 'doing');

  // THỐNG KÊ
  print('\nThống kê: ${listTask.thongKe}');
}
