// ============================================================
// Câu 3: Lớp Task – Đối tượng công việc trong dự án TaskFlow
// ============================================================
import 'package:intl/intl.dart';

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

  /// Trạng thái: todo / doing / reviewing / done / cancelled / archived
  String status;

  /// Hạn hoàn thành (dùng DateTime thay vì String để tránh parse lặp)
  DateTime deadline;

  // ─── CHÈN THÊM CÁC THUỘC TÍNH NÀY ĐỂ ĐỔ LÊN GIAO DIỆN (UI) ───
  String assigneeName; // Tên hiển thị người được gán (Ví dụ: Tran B)
  String assigneeAvatar; // Ký tự chữ cái làm avatar tròn (Ví dụ: B, C)
  bool isUrgent; // Cờ báo công việc khẩn cấp (Hiển thị biểu tượng lịch màu đỏ)
  DateTime updatedAt; // Ngày cập nhật gần nhất để xử lý xung đột đồng bộ
  String rejectionReason; // Lý do từ chối công việc
  int isSynced; // Cờ trạng thái đồng bộ SQLite: 0 (chưa sync), 1 (đã sync)

  // ================== DANH SÁCH TRẠNG THÁI HỢP LỆ ==================

  /// Tất cả các trạng thái hợp lệ của một Task
  static const List<String> validStatuses = [
    'todo', 'doing', 'reviewing', 'done', 'cancelled', 'archived',
  ];

  /// Ma trận chuyển đổi trạng thái hợp lệ (Adjacency List)
  /// - todo → doing (Member nhận việc), cancelled (Manager hủy)
  /// - doing → reviewing (Member nộp bài), todo (quay lại), cancelled (Manager hủy)
  /// - reviewing → done (Manager duyệt), todo (Manager từ chối), cancelled (Manager hủy)
  /// - done → archived (Manager lưu trữ)
  /// - cancelled, archived → không chuyển tiếp được (Trạng thái cuối cùng)
  static final Map<String, Set<String>> allowedTransitions = {
    'todo': {'doing', 'cancelled'},
    'doing': {'reviewing', 'todo', 'cancelled'},
    'reviewing': {'done', 'todo', 'cancelled'},
    'done': {'archived'},
    'cancelled': <String>{},
    'archived': <String>{},
  };

  // ================== CONSTRUCTOR ==================

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.projectId,
    required this.assignedTo,
    required this.status,
    required this.deadline,
    // Giá trị mặc định để không lỗi các chỗ cũ gọi Constructor
    this.assigneeName = '',
    this.assigneeAvatar = '',
    this.isUrgent = false,
    DateTime? updatedAt,
    this.rejectionReason = '',
    this.isSynced = 1,
  }) : updatedAt = (updatedAt ?? DateTime.now()).toUtc();

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
      // ─── CHÈN THÊM ĐỂ BÓC TÁCH DỮ LIỆU UI CỦA TASK ───
      assigneeName: data['assigneeName'] ?? '',
      assigneeAvatar: data['assigneeAvatar'] ?? '',
      isUrgent: (data['isUrgent'] == 1 || data['isUrgent'] == true),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      rejectionReason: data['rejectionReason'] ?? '',
      isSynced: data['isSynced'] ?? 1,
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
      // ─── CHÈN THÊM ĐỂ ĐẨY LÊN DATABASE ───
      'assigneeName': assigneeName,
      'assigneeAvatar': assigneeAvatar,
      'isUrgent': isUrgent,
      'updatedAt': updatedAt.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? assignedTo,
    String? status,
    DateTime? deadline,
    String? assigneeName,
    String? assigneeAvatar,
    bool? isUrgent,
    DateTime? updatedAt,
    String? rejectionReason,
    int? isSynced,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
      isUrgent: isUrgent ?? this.isUrgent,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Kiểm tra xem có thể chuyển sang trạng thái mới hay không
  bool canTransitionTo(String newStatus) {
    return allowedTransitions[status]?.contains(newStatus) ?? false;
  }

  /// Kiểm tra tính hợp lệ của việc chuyển trạng thái (trả về thông báo lỗi hoặc null nếu hợp lệ)
  static String? validateTransition(String current, String next) {
    if (!validStatuses.contains(next)) {
      return "Trạng thái '$next' không hợp lệ";
    }
    if (!(allowedTransitions[current]?.contains(next) ?? false)) {
      return "Không thể chuyển từ '$current' sang '$next'";
    }
    return null; // Hợp lệ
  }

  /// Cập nhật trạng thái task theo ma trận chuyển đổi hợp lệ
  /// Trả về `Future<bool>` để hỗ trợ xử lý bất đồng bộ và báo lỗi
  Future<bool> updateStatus(String newStatus) async {
    final error = validateTransition(status, newStatus);
    if (error != null) return false;

    status = newStatus;
    return true;
  }

  /// Kiểm tra task có quá hạn không (không cần try/catch vì deadline đã là DateTime)
  bool isOverdue() {
    return status != 'done' && DateTime.now().isAfter(deadline.toLocal());
  }

  /// Định dạng deadline hiển thị dạng dd/MM/yyyy dùng package intl
  String get deadlineFormatted {
    return DateFormat('dd/MM/yyyy').format(deadline.toLocal());
  }

  /// Định dạng ngày rút gọn: dd/MM (hiển thị trên card nhỏ)
  String get deadlineShort {
    return DateFormat('dd/MM').format(deadline.toLocal());
  }

  /// Định dạng đầy đủ có giờ: HH:mm dd/MM/yyyy
  String get deadlineFull {
    return DateFormat('HH:mm dd/MM/yyyy').format(deadline.toLocal());
  }

  /// Override toString để hiển thị nhanh
  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, '
        'assignedTo: $assignedTo, deadline: $deadlineFormatted)';
  }
}
