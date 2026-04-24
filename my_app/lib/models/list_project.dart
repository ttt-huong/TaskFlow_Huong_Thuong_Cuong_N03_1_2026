// ============================================================
// ListProject – Danh sách dự án với CRUD
// ============================================================

import 'project_model.dart';

/// ListProject chứa danh sách các ProjectModel và cung cấp các thao tác CRUD:
/// - Create: Tạo mới 1 project
/// - Read  : Đọc tất cả các project
/// - Update: Sửa 1 project theo id
/// - Delete: Xóa 1 project theo id
class ListProject {
  // ================== BIẾN ==================

  /// Danh sách các ProjectModel
  List<ProjectModel> _projects = [];

  // ================== GETTER ==================

  /// Lấy danh sách project (read-only)
  List<ProjectModel> get projects => List.unmodifiable(_projects);

  /// Lấy số lượng project
  int get length => _projects.length;

  // ================== CREATE ==================

  /// Tạo 01 bản ghi có kiểu ProjectModel và lưu giữ vào danh sách
  void create(ProjectModel project) {
    _projects.add(project);
  }

  // ================== READ ==================

  /// Đọc tất cả các bản ghi có trong ListProject

  /// Tìm project theo ID
  ProjectModel? findById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // ================== UPDATE (EDIT) ==================

  /// Sửa 01 bản ghi có kiểu ProjectModel, có id cụ thể và lưu giữ vào ListProject
  bool edit(String id, {
    String? name,
    String? description,
    List<String>? memberIds,
  }) {
    int index = _projects.indexWhere((project) => project.id == id);

    if (index == -1) {
      print('⚠ Không tìm thấy project với ID: $id để sửa!');
      return false;
    }

    ProjectModel project = _projects[index];

    if (name != null) project.name = name;
    if (description != null) project.description = description;
    if (memberIds != null) project.memberIds = memberIds;

    return true;
  }

  // ================== DELETE ==================

  /// Xóa project theo ID
  bool delete(String id) {
    int lengthBefore = _projects.length;
    _projects.removeWhere((project) => project.id == id);

    if (_projects.length < lengthBefore) {
      return true;
    } else {
      return false;
    }
  }

  // ================== THỐNG KÊ ==================

  /// Thống kê số project và tổng thành viên
  Map<String, int> get thongKe {
    int totalMembers = 0;
    for (var project in _projects) {
      totalMembers += project.memberIds.length;
    }

    return {'projects': _projects.length, 'totalMembers': totalMembers};
  }
}
