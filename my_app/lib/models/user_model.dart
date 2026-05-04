// ============================================================
// UserModel – Đối tượng người dùng trong dự án TaskFlow
// ============================================================

class UserModel {
  String id;
  String name;
  String email;
  String password;
  String role; // 'manager' hoặc 'member'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '123456', // Default cho dữ liệu cũ
      role: data['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  bool get isManager => role == 'manager';

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
