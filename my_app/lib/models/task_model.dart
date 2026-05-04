// ============================================================
// Câu 3: Lớp Task – Đối tượng công việc trong dự án TaskFlow
// ============================================================

/// Task là một đối tượng cụ thể trong bài tập lớn TaskFlow.
/// Mỗi Task đại diện cho một công việc được giao cho thành viên
/// trong một dự án (Project).
class Task {
  // ================== BIẾN (Thuộc tính) ==================

  /// ID công việc (duy nhất)
  String id;

  /// Tên công việc
  String title;

  /// Mô tả chi tiết công việc
  String description;

  /// ID dự án chứa task này
  String projectId;

  /// ID người được giao task
  String assignedTo;

  /// Trạng thái: todo / doing / done
  String status;

  /// Hạn hoàn thành (dùng DateTime thay vì String để tránh parse lặp)
  DateTime deadline;

  // ================== CONSTRUCTOR ==================

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.projectId,
    required this.assignedTo,
    required this.status,
    required this.deadline,
  });

  // ================== PHƯƠNG THỨC ==================

  /// Chuyển đổi từ Map sang Task (dùng khi đọc từ Firestore/SQLite)
  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      projectId: data['projectId'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      status: data['status'] ?? 'todo',
      deadline: DateTime.tryParse(data['deadline'] ?? '') ?? DateTime.now(),
    );
  }

  /// Chuyển đổi từ Task sang Map (dùng khi ghi lên Firestore/SQLite)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'projectId': projectId,
      'assignedTo': assignedTo,
      'status': status,
      'deadline': deadline.toIso8601String(),
    };
  }

  /// Cập nhật trạng thái task theo luồng: todo → doing → reviewing → done
  /// Chỉ cho phép chuyển trạng thái hợp lệ theo đúng thứ tự
  bool updateStatus(String newStatus) {
    const validTransitions = {
      'todo': ['doing'],
      'doing': ['reviewing'],
      'reviewing': ['done', 'doing'], // Duyệt xong hoặc yêu cầu sửa lại
      'done': <String>[], 
    };

    final allowed = validTransitions[status] ?? [];
    if (!allowed.contains(newStatus)) return false;

    status = newStatus;
    return true;
  }

  /// Kiểm tra task có quá hạn không (không cần try/catch vì deadline đã là DateTime)
  bool isOverdue() {
    return status != 'done' && DateTime.now().isAfter(deadline);
  }

  /// Định dạng deadline hiển thị: YYYY-MM-DD
  String get deadlineFormatted {
    return '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
  }

  /// Override toString để hiển thị nhanh
  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, '
        'assignedTo: $assignedTo, deadline: $deadlineFormatted)';
  }
}
