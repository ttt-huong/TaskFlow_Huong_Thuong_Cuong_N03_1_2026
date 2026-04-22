// ============================================================
// Câu 3: ListTask – Danh sách công việc với CRUD
// ============================================================

import 'task_model.dart';

/// ListTask chứa danh sách các Task và cung cấp các thao tác CRUD:
/// - Create: Tạo mới 1 task
/// - Read  : Đọc tất cả các task
/// - Update: Sửa 1 task theo id
/// - Delete: (mở rộng) Xóa 1 task theo id
class ListTask {
  // ================== BIẾN ==================

  /// Danh sách các Task
  List<Task> _tasks = [];

  // ================== GETTER ==================

  /// Lấy danh sách task (read-only)
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Lấy số lượng task
  int get length => _tasks.length;

  // ================== CREATE ==================

  /// Tạo 01 bản ghi có kiểu Task và lưu giữ vào danh sách
  void create(Task task) {
    _tasks.add(task);
    print('✔ Đã tạo task: "${task.title}" (ID: ${task.id})');
  }

  // ================== READ ==================

  /// Đọc tất cả các bản ghi có trong ListTask
  void readAll() {
    print('');
    print('╔══════════════════════════════════════════╗');
    print('║     📋 DANH SÁCH TẤT CẢ CÔNG VIỆC       ║');
    print('╠══════════════════════════════════════════╣');
    print('║  Tổng số task: ${_tasks.length.toString().padRight(25)}║');
    print('╚══════════════════════════════════════════╝');

    if (_tasks.isEmpty) {
      print('  (Danh sách trống - chưa có task nào)');
      return;
    }

    for (var task in _tasks) {
      task.printInfo();
    }
    print('');
  }

  /// Tìm task theo ID
  Task? findById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      print('⚠ Không tìm thấy task với ID: $id');
      return null;
    }
  }

  // ================== UPDATE (EDIT) ==================

  /// Sửa 01 bản ghi có kiểu Task, có id cụ thể và lưu giữ vào ListTask
  /// Trả về true nếu sửa thành công, false nếu không tìm thấy
  bool edit(String id, {
    String? title,
    String? projectId,
    String? assignedTo,
    String? status,
    String? deadline,
  }) {
    // Tìm vị trí task cần sửa
    int index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) {
      print('⚠ Không tìm thấy task với ID: $id để sửa!');
      return false;
    }

    // Cập nhật các trường được truyền vào
    Task task = _tasks[index];

    if (title != null) task.title = title;
    if (projectId != null) task.projectId = projectId;
    if (assignedTo != null) task.assignedTo = assignedTo;
    if (deadline != null) task.deadline = deadline;

    // Cập nhật trạng thái (có kiểm tra luồng)
    if (status != null) {
      task.updateStatus(status);
    }

    print('✔ Đã sửa task ID: $id thành công!');
    return true;
  }

  // ================== DELETE (mở rộng) ==================

  /// Xóa task theo ID
  bool delete(String id) {
    int lengthBefore = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);

    if (_tasks.length < lengthBefore) {
      print('✔ Đã xóa task với ID: $id');
      return true;
    } else {
      print('⚠ Không tìm thấy task với ID: $id để xóa!');
      return false;
    }
  }

  // ================== THỐNG KÊ ==================

  /// Đếm số task theo trạng thái
  Map<String, int> thongKe() {
    int todo = _tasks.where((t) => t.status == 'todo').length;
    int doing = _tasks.where((t) => t.status == 'doing').length;
    int done = _tasks.where((t) => t.status == 'done').length;
    int overdue = _tasks.where((t) => t.isOverdue()).length;

    print('');
    print('📊 THỐNG KÊ:');
    print('   Todo  : $todo');
    print('   Doing : $doing');
    print('   Done  : $done');
    print('   Quá hạn: $overdue');
    print('   Tổng  : ${_tasks.length}');

    return {'todo': todo, 'doing': doing, 'done': done, 'overdue': overdue};
  }
}
