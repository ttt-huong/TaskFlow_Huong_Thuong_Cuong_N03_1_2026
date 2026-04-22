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

  /// ID dự án chứa task này
  String projectId;

  /// ID người được giao task
  String assignedTo;

  /// Trạng thái: todo / doing / done
  String status;

  /// Hạn hoàn thành (YYYY-MM-DD)
  String deadline;

  // ================== CONSTRUCTOR ==================

  Task({
    required this.id,
    required this.title,
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
      projectId: data['projectId'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      status: data['status'] ?? 'todo',
      deadline: data['deadline'] ?? '',
    );
  }

  /// Chuyển đổi từ Task sang Map (dùng khi ghi lên Firestore/SQLite)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'projectId': projectId,
      'assignedTo': assignedTo,
      'status': status,
      'deadline': deadline,
    };
  }

  /// Cập nhật trạng thái task theo luồng: todo → doing → done
  /// Không cho phép nhảy trực tiếp từ todo → done
  bool updateStatus(String newStatus) {
    if (status == 'todo' && newStatus == 'done') {
      print('⚠ Không thể chuyển trực tiếp từ "todo" sang "done"!');
      print('  Phải chuyển qua "doing" trước.');
      return false;
    }
    status = newStatus;
    print('✔ Cập nhật trạng thái task "$title" → $status');
    return true;
  }

  /// Kiểm tra task có quá hạn không
  bool isOverdue() {
    try {
      DateTime deadlineDate = DateTime.parse(deadline);
      return status != 'done' && DateTime.now().isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  /// In ra thông tin chi tiết của task
  void printInfo() {
    print('────────────────────────────────');
    print('📋 Task: $title');
    print('   ID          : $id');
    print('   Project ID  : $projectId');
    print('   Assigned To : $assignedTo');
    print('   Status      : $status');
    print('   Deadline    : $deadline');
    if (isOverdue()) {
      print('   ⚠ CẢNH BÁO  : Task đã QUÁ HẠN!');
    }
    print('────────────────────────────────');
  }

  /// Override toString để hiển thị nhanh
  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, '
        'assignedTo: $assignedTo, deadline: $deadline)';
  }
}
