// ============================================================
// ProjectModel – Đối tượng dự án trong dự án TaskFlow
// ============================================================

class ProjectModel {
  String id;
  String name;
  String description;
  List<String> memberIds;
  DateTime updatedAt;
  int isSynced; // Cờ trạng thái đồng bộ SQLite: 0 (chưa sync), 1 (đã sync)

  // ─── CHÈN THÊM CÁC THUỘC TÍNH NÀY ĐỂ HIỂN THỊ UI ───
  int todoCount;
  int doingCount;
  int doneCount;
  double progress;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    DateTime? updatedAt,
    this.isSynced = 1,

    this.todoCount = 0,
    this.doingCount = 0,
    this.doneCount = 0,
    this.progress = 0.0,
  }) : updatedAt = (updatedAt ?? DateTime.now()).toUtc();

  factory ProjectModel.fromMap(Map<String, dynamic> data, String id) {
    return ProjectModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      isSynced: data['isSynced'] ?? 1,
      // ─── CHÈN THÊM ĐỂ ĐỌC DỮ LIỆU TỪ FIREBASE/MOCK DATA ───
      todoCount: data['todoCount'] ?? 0,
      doingCount: data['doingCount'] ?? 0,
      doneCount: data['doneCount'] ?? 0,
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'updatedAt': updatedAt.toIso8601String(),

      'todoCount': todoCount,
      'doingCount': doingCount,
      'doneCount': doneCount,
      'progress': progress,
    };
  }

  void addMember(String userId) {
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
    }
  }

  @override
  String toString() =>
      'ProjectModel(id: $id, name: $name, progress: $progress%)';
}
