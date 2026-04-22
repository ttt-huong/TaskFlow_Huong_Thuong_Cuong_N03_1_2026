// ============================================================
// ProjectModel – Đối tượng dự án trong dự án TaskFlow
// ============================================================

class ProjectModel {
  String id;
  String name;
  String description;
  List<String> memberIds;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data, String id) {
    return ProjectModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'memberIds': memberIds,
    };
  }

  void addMember(String userId) {
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
    }
  }

  void printInfo() {
    print('📁 Project: $name (ID: $id)');
    print('   Mô tả: $description');
    print('   Thành viên: ${memberIds.join(', ')}');
  }

  @override
  String toString() => 'ProjectModel(id: $id, name: $name)';
}
