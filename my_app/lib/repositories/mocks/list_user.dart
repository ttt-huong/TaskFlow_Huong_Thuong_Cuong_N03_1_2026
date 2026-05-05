// ============================================================
// ListUser – Danh sách người dùng với CRUD
// ============================================================

import '../../models/user_model.dart';
import '../../core/seed_data.dart';

class ListUser {
  // ================== SINGLETON ==================
  static final ListUser _instance = ListUser._internal();
  factory ListUser() => _instance;
  ListUser._internal();

  // ================== BIẾN ==================

  /// Danh sách các UserModel
  final List<UserModel> _users = List.from(SeedData.initialUsers);

  // ================== GETTER ==================

  /// Lấy danh sách user (read-only)
  List<UserModel> get users => List.unmodifiable(_users);

  /// Lấy số lượng user
  int get length => _users.length;

  // ================== CREATE ==================

  /// Tạo 01 bản ghi có kiểu UserModel và lưu giữ vào danh sách
  /// Trả về false nếu ID đã tồn tại hoặc dữ liệu không hợp lệ
  bool create(UserModel user) {
    if (user.id.isEmpty) return false;
    if (user.name.isEmpty) return false;
    if (user.email.isEmpty) return false;
    if (_users.any((u) => u.id == user.id)) return false;
    _users.add(user);
    return true;
  }

  // ================== READ ==================

  /// Đọc tất cả các bản ghi có trong ListUser

  /// Tìm user theo ID
  UserModel? findById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Tìm user theo Email
  UserModel? findByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // ================== UPDATE (EDIT) ==================

  /// Sửa 01 bản ghi có kiểu UserModel, có id cụ thể và lưu giữ vào ListUser
  bool edit(String id, {String? name, String? email, String? role}) {
    int index = _users.indexWhere((user) => user.id == id);

    if (index == -1) {
      return false;
    }

    UserModel user = _users[index];

    if (name != null) user.name = name;
    if (email != null) user.email = email;
    if (role != null) user.role = role;

    return true;
  }

  // ================== DELETE ==================

  /// Xóa user theo ID
  bool delete(String id) {
    int lengthBefore = _users.length;
    _users.removeWhere((user) => user.id == id);

    if (_users.length < lengthBefore) {
      return true;
    } else {
      return false;
    }
  }

  // ================== THỐNG KÊ ==================

  /// Đếm số user theo role
  Map<String, int> get thongKe {
    return {
      'manager': _users.where((u) => u.role == 'manager').length,
      'member': _users.where((u) => u.role == 'member').length,
      'total': _users.length,
    };
  }
}
