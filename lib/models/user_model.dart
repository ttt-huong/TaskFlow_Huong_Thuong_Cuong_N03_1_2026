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
    required this.role,
    // Gán giá trị mặc định để các hàm đăng ký/đăng nhập cũ không bị lỗi compile
    this.avatarChar = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    String userName = data['name'] ?? '';
    return UserModel(
      id: id,
      name: userName,
      email: data['email'] ?? '',
      password: data['password'] ?? '', // Default rỗng — không dùng '123456' vì lý do bảo mật
      role: data['role'] ?? 'member',
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

  bool get isManager => role == 'manager';

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
