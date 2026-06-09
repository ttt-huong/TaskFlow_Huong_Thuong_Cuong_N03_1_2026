// ============================================================
// UserModel – Đối tượng người dùng trong dự án TaskFlow
// ============================================================

class UserModel {
  String id;
  String name;
  String email;
  String password;
  String role; // 'manager' hoặc 'member'

  // ─── CHÈN THÊM THUỘC TÍNH NÀY ĐỂ LÀM AVATAR TRÒN TRÊN UI ───
  String avatarChar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required String role,
    // Gán giá trị mặc định để các hàm đăng ký/đăng nhập cũ không bị lỗi compile
    this.avatarChar = '',
  }) : role = role.trim().toLowerCase();

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    String userName = data['name'] ?? '';
    final String roleValue = (data['role'] as String?)?.trim().toLowerCase() ?? 'member';
    return UserModel(
      id: id,
      name: userName,
      email: data['email'] ?? '',
      password: data['password'] ?? '123456', // Default cho dữ liệu cũ
      role: roleValue,
      // Tự động lấy chữ cái đầu tiên của Tên để làm Avatar nếu DB chưa lưu trường này
      avatarChar:
          data['avatarChar'] ??
          (userName.isNotEmpty ? userName[0].toUpperCase() : 'U'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      // Đẩy lên cả trường avatarChar để đồng bộ với Firebase/Database
      'avatarChar': avatarChar,
    };
  }

  bool get isManager => role.trim().toLowerCase() == 'manager';

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
