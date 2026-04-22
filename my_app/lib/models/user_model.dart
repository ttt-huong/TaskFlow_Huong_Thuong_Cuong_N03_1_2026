// ============================================================
// UserModel – Đối tượng người dùng trong dự án TaskFlow
// ============================================================

class UserModel {
  String id;
  String name;
  String email;
  String role; // 'manager' hoặc 'member'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  bool get isManager => role == 'manager';

  void printInfo() {
    print('👤 User: $name (ID: $id) - Role: $role - Email: $email');
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
