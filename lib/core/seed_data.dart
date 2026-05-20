import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

class SeedData {
  static final List<UserModel> initialUsers = [
    UserModel(id: 'U001', name: 'Nguyễn Quản Lý', email: 'manager@taskflow.com', password: '123', role: 'manager'),
    UserModel(id: 'U002', name: 'Trần Nhân Viên A', email: 'member1@taskflow.com', password: '123', role: 'member'),
    UserModel(id: 'U003', name: 'Lê Nhân Viên B', email: 'member2@taskflow.com', password: '123', role: 'member'),
  ];

  static final List<ProjectModel> initialProjects = [
    ProjectModel(
      id: 'P001',
      name: 'Dự án TaskFlow',
      description: 'Hệ thống quản lý công việc thông minh',
      memberIds: ['U001', 'U002', 'U003'],
    ),
    ProjectModel(
      id: 'P002',
      name: 'Mobile App Project',
      description: 'Phát triển ứng dụng di động cho khách hàng',
      memberIds: ['U001', 'U002'],
    ),
  ];

  static final List<Task> initialTasks = [
    Task(
      id: 'T001',
      title: 'Thiết kế Database',
      projectId: 'P001',
      assignedTo: 'U002',
      status: 'done',
      deadline: DateTime(2026, 4, 15),
    ),
    Task(
      id: 'T002',
      title: 'Xây dựng UI Login',
      projectId: 'P001',
      assignedTo: 'U002',
      status: 'doing',
      deadline: DateTime(2026, 5, 01),
    ),
    Task(
      id: 'T003',
      title: 'Viết API Service',
      projectId: 'P001',
      assignedTo: 'U003',
      status: 'reviewing',
      deadline: DateTime(2026, 5, 05),
    ),
    Task(
      id: 'T004',
      title: 'Kiểm thử tính năng',
      projectId: 'P001',
      assignedTo: 'U003',
      status: 'todo',
      deadline: DateTime(2026, 5, 10),
    ),
    Task(
      id: 'T005',
      title: 'Viết tài liệu HDSD',
      projectId: 'P002',
      assignedTo: 'U002',
      status: 'done',
      deadline: DateTime(2026, 4, 20),
    ),
    Task(
      id: 'T006',
      title: 'Họp khởi động dự án', // Task quá hạn
      projectId: 'P002',
      assignedTo: 'U002',
      status: 'todo',
      deadline: DateTime(2026, 4, 20),
    ),
  ];
}
