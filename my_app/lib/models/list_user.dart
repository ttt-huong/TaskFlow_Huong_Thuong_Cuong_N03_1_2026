// ============================================================
// ListUser – Danh sách người dùng với CRUD
// ============================================================

import 'user_model.dart';

/// ListUser chứa danh sách các UserModel và cung cấp các thao tác CRUD:
/// - Create: Tạo mới 1 user
/// - Read  : Đọc tất cả các user
/// - Update: Sửa 1 user theo id
/// - Delete: Xóa 1 user theo id
class ListUser {
  // ================== BIẾN ==================

  /// Danh sách các UserModel
  List<UserModel> _users = [];

  // ================== GETTER ==================

  /// Lấy danh sách user (read-only)
  List<UserModel> get users => List.unmodifiable(_users);

  /// Lấy số lượng user
  int get length => _users.length;

  // ================== CREATE ==================

  /// Tạo 01 bản ghi có kiểu UserModel và lưu giữ vào danh sách
  void create(UserModel user) {
    _users.add(user);
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

  // ================== UPDATE (EDIT) ==================

  /// Sửa 01 bản ghi có kiểu UserModel, có id cụ thể và lưu giữ vào ListUser
  bool edit(String id, {
    String? name,
    String? email,
    String? role,
  }) {
    int index = _users.indexWhere((user) => user.id == id);

    if (index == -1) {
      print('⚠ Không tìm thấy user với ID: $id để sửa!');
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
