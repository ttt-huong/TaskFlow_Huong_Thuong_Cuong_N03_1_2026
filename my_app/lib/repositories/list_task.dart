// ============================================================
// Câu 3: ListTask – Danh sách công việc với CRUD
// ============================================================

import '../models/task_model.dart';

/// ListTask chứa danh sách các Task và cung cấp các thao tác CRUD:
/// - Create: Tạo mới 1 task
/// - Read  : Đọc tất cả các task
/// - Update: Sửa 1 task theo id
/// - Delete: (mở rộng) Xóa 1 task theo id
class ListTask {
  // ================== BIẾN ==================

  /// Danh sách các Task
  final List<Task> _tasks = [];

  // ================== GETTER ==================

  /// Lấy danh sách task (read-only)
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Lấy số lượng task
  int get length => _tasks.length;

  // ================== CREATE ==================

  /// Tạo 01 bản ghi có kiểu Task và lưu giữ vào danh sách
  /// Trả về false nếu ID đã tồn tại hoặc dữ liệu không hợp lệ
  bool create(Task task) {
    // Validation đầu vào
    if (task.id.isEmpty) return false;
    if (task.title.isEmpty) return false;
    if (task.assignedTo.isEmpty) return false;
    if (_tasks.any((t) => t.id == task.id)) return false;
    _tasks.add(task);
    return true;
  }

  // ================== READ ==================

  /// Đọc tất cả các bản ghi có trong ListTask

  /// Tìm task theo ID
  Task? findById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // ================== UPDATE (EDIT) ==================

  /// Sửa 01 bản ghi có kiểu Task, có id cụ thể và lưu giữ vào ListTask
  /// Trả về true nếu sửa thành công, false nếu không tìm thấy
  bool edit(String id, {
    String? title,
    String? description,
    String? projectId,
    String? assignedTo,
    String? status,
    DateTime? deadline,
  }) {
    // Tìm vị trí task cần sửa
    int index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) {
      return false;
    }

    // Cập nhật các trường được truyền vào
    Task task = _tasks[index];

    if (title != null) task.title = title;
    if (description != null) task.description = description;
    if (projectId != null) task.projectId = projectId;
    if (assignedTo != null) task.assignedTo = assignedTo;
    if (deadline != null) task.deadline = deadline;

    // Cập nhật trạng thái (có kiểm tra luồng)
    if (status != null) {
      task.updateStatus(status);
    }

    return true;
  }

  // ================== DELETE (mở rộng) ==================

  /// Xóa task theo ID
  bool delete(String id) {
    int lengthBefore = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);

    if (_tasks.length < lengthBefore) {
      return true;
    } else {
      return false;
    }
  }

  // ================== ORPHAN TASKS ==================

  /// Xóa tất cả task thuộc một project (xử lý orphan khi xóa project)
  int deleteTasksByProject(String projectId) {
    int lengthBefore = _tasks.length;
    _tasks.removeWhere((task) => task.projectId == projectId);
    return lengthBefore - _tasks.length;
  }

  // ================== THỐNG KÊ ==================

  /// Đếm số task theo trạng thái
  Map<String, int> get thongKe {
    return {
      'todo': _tasks.where((t) => t.status == 'todo').length,
      'doing': _tasks.where((t) => t.status == 'doing').length,
      'done': _tasks.where((t) => t.status == 'done').length,
      'overdue': _tasks.where((t) => t.isOverdue()).length,
      'total': _tasks.length,
    };
  }
}
