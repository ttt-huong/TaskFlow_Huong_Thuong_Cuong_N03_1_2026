import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/auth_provider.dart';
import 'package:my_app/providers/project_provider.dart';
import 'package:my_app/providers/task_provider.dart';
import 'package:my_app/providers/connectivity_provider.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/models/project_model.dart';
import 'package:my_app/models/task_model.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/screens/project_task_screen.dart';
import 'package:my_app/screens/task_detail_screen.dart';
import 'package:my_app/providers/notification_provider.dart';
import 'package:my_app/models/notification_model.dart';

// Mocks
class MockNotificationProvider extends NotificationProvider {
  @override
  List<NotificationModel> get notifications => [];
  @override
  int get unreadCount => 0;
  @override
  Future<void> loadNotifications([String? userId]) async {}
  @override
  Future<void> markAllAsRead() async {}
  @override
  Future<void> markAsRead(String id) async {}
  @override
  Future<void> addNotification(NotificationModel notification) async {}
}

class MockAuthProvider extends AuthProvider {
  UserModel? _currentUser;
  
  @override
  UserModel? get currentUser => _currentUser;
  
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}

class MockProjectProvider extends ProjectProvider {
  List<ProjectModel> _projects = [];
  List<UserModel> _allUsers = [
    UserModel(id: 'u1', name: 'Member 1', email: 'm1@test.com', role: 'member', password: ''),
  ];

  @override
  bool get isLoading => false;
  
  @override
  List<ProjectModel> get projects => _projects;
  
  void setProjects(List<ProjectModel> p) {
    _projects = p;
    notifyListeners();
  }

  @override
  List<UserModel> get allUsers => _allUsers;

  void setAllUsers(List<UserModel> u) {
    _allUsers = u;
    notifyListeners();
  }
  
  @override
  Future<void> loadAllUsers() async {}

  @override
  Future<void> loadProjects(UserModel currentUser) async {}

  @override
  Future<void> updateProject(ProjectModel project) async {}
}

class MockTaskProvider extends TaskProvider {
  List<Task> _tasks = [];
  String? updatedTaskId;
  String? updatedTaskStatus;
  String? deletedTaskId;
  Task? editedTask;
  String? approvedTaskId;
  String? rejectedTaskId;
  String? rejectReason;
  
  @override
  bool get isLoading => false;
  
  @override
  List<Task> get tasks => _tasks;
  
  void setTasks(List<Task> t) {
    _tasks = t;
    notifyListeners();
  }
  
  @override
  Future<void> loadTasksByProject(String projectId) async {}
  
  @override
  Future<void> loadMyTasks(String userId) async {}
  
  @override
  Future<void> loadAllTasks([String userId = '']) async {}
  
  @override
  Future<bool> updateTaskStatus(String id, String status) async {
    updatedTaskId = id;
    updatedTaskStatus = status;
    return true;
  }
  
  @override
  Future<void> deleteTask(String id) async {
    deletedTaskId = id;
  }

  @override
  Future<void> editTask(Task task) async {
    editedTask = task;
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
    notifyListeners();
  }

  @override
  Future<bool> approveTask(String id) async {
    approvedTaskId = id;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(status: 'done');
      notifyListeners();
    }
    return true;
  }

  @override
  Future<bool> rejectTask(String id, String reason) async {
    rejectedTaskId = id;
    rejectReason = reason;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _tasks[index] = _tasks[index].copyWith(status: 'todo', rejectionReason: reason);
      notifyListeners();
    }
    return true;
  }
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockProjectProvider mockProjectProvider;
  late MockTaskProvider mockTaskProvider;

  final managerUser = UserModel(
    id: 'mgr',
    name: 'Manager',
    email: 'mgr@test.com',
    role: 'manager',
    password: '',
  );

  final memberUser = UserModel(
    id: 'u1',
    name: 'Member 1',
    email: 'u1@test.com',
    role: 'member',
    password: '',
  );

  final taskAssignedToMe = Task(
    id: 't1',
    title: 'Task for me',
    description: 'Desc',
    projectId: 'p1',
    assignedTo: 'u1',
    status: 'todo',
    deadline: DateTime.now().add(const Duration(days: 1)),
    assigneeName: 'Member 1',
    assigneeAvatar: 'M',
    isUrgent: false,
    updatedAt: DateTime.now(),
  );

  final taskReviewing = Task(
    id: 't2',
    title: 'Task reviewing',
    description: 'Desc',
    projectId: 'p1',
    assignedTo: 'u1',
    status: 'reviewing',
    deadline: DateTime.now().add(const Duration(days: 1)),
    assigneeName: 'Member 1',
    assigneeAvatar: 'M',
    isUrgent: false,
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockProjectProvider = MockProjectProvider();
    mockTaskProvider = MockTaskProvider();
  });

  Widget createMainScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ProjectProvider>.value(value: mockProjectProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: mockTaskProvider),
        ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider<NotificationProvider>.value(value: MockNotificationProvider()),
      ],
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }

  Widget createProjectTaskScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ProjectProvider>.value(value: mockProjectProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: mockTaskProvider),
        ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider<NotificationProvider>.value(value: MockNotificationProvider()),
      ],
      child: const MaterialApp(
        home: ProjectTaskScreen(projectId: 'p1', projectName: 'Test Project'),
      ),
    );
  }

  Widget createTaskDetailScreen(Task task) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: mockTaskProvider),
        ChangeNotifierProvider<ProjectProvider>.value(value: mockProjectProvider),
        ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider<NotificationProvider>.value(value: MockNotificationProvider()),
      ],
      child: MaterialApp(
        home: TaskDetailScreen(task: task),
      ),
    );
  }

  testWidgets('A1. Manager sees 4 tabs and FAB on MainScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(managerUser);
    await tester.pumpWidget(createMainScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('A2. Member sees 3 tabs and NO FAB on MainScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(memberUser);
    await tester.pumpWidget(createMainScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.group_outlined), findsNothing);
    
    expect(find.byType(FloatingActionButton), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('B1. Tap Task in ProjectTaskScreen navigates to TaskDetailScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(memberUser);
    mockTaskProvider.setTasks([taskAssignedToMe]);
    
    await tester.pumpWidget(createProjectTaskScreen());
    await tester.pumpAndSettle();

    expect(find.text('Task for me'), findsOneWidget);
    
    await tester.tap(find.text('Task for me'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết nhiệm vụ'), findsOneWidget);
    
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('C1. Member clicks BẮT ĐẦU LÀM triggers updateTaskStatus to doing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(memberUser);
    await tester.pumpWidget(createTaskDetailScreen(taskAssignedToMe));
    await tester.pumpAndSettle();

    final btn = find.text('BẮT ĐẦU LÀM');
    expect(btn, findsOneWidget);
    
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pumpAndSettle();

    expect(mockTaskProvider.updatedTaskId, 't1');
    expect(mockTaskProvider.updatedTaskStatus, 'doing');

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('D1. Manager sees Edit/Delete and Approve/Reject on reviewing task', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(managerUser);
    await tester.pumpWidget(createTaskDetailScreen(taskReviewing));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    
    expect(find.text('Từ chối'), findsOneWidget);
    expect(find.text('DUYỆT'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('D2. Member does NOT see Edit/Delete and Approve/Reject', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(memberUser);
    await tester.pumpWidget(createTaskDetailScreen(taskReviewing));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
    
    expect(find.text('Từ chối'), findsNothing);
    expect(find.text('DUYỆT'), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('E1. Removing project member with incomplete task shows warning dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(managerUser);

    final project = ProjectModel(
      id: 'p1',
      name: 'Test Project',
      description: 'Desc',
      memberIds: ['mgr', 'u1'],
    );
    mockProjectProvider.setProjects([project]);
    mockProjectProvider.setAllUsers([
      managerUser,
      UserModel(id: 'u1', name: 'Member 1', email: 'm1@test.com', role: 'member', password: ''),
    ]);

    mockTaskProvider.setTasks([taskAssignedToMe]); // assignedTo: 'u1', status: 'todo'

    await tester.pumpWidget(createProjectTaskScreen());
    await tester.pumpAndSettle();

    final manageBtn = find.byIcon(Icons.people_alt_outlined);
    expect(manageBtn, findsOneWidget);
    await tester.tap(manageBtn);
    await tester.pumpAndSettle();

    expect(find.text('Quản lý thành viên'), findsOneWidget);

    final checkboxTile = find.widgetWithText(CheckboxListTile, 'Member 1');
    expect(checkboxTile, findsOneWidget);
    await tester.tap(checkboxTile);
    await tester.pumpAndSettle();

    final saveBtn = find.text('Lưu lại');
    expect(saveBtn, findsOneWidget);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining(RegExp('không thể xóa các thành viên sau vì họ vẫn còn công việc chưa hoàn thành', caseSensitive: false)), findsOneWidget);

    final okBtn = find.text('Đã hiểu');
    expect(okBtn, findsOneWidget);
    await tester.tap(okBtn);
    await tester.pumpAndSettle();

    expect(find.text('Không thể xóa thành viên'), findsNothing);
    expect(find.text('Quản lý thành viên'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('F1. Member can see all tasks in a project, not just their own', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    mockAuthProvider.setCurrentUser(memberUser);

    final task1 = Task(
      id: 't1',
      title: 'Task Assigned to Me',
      projectId: 'p1',
      assignedTo: 'u1',
      status: 'todo',
      deadline: DateTime.now().add(const Duration(days: 1)),
    );

    final task2 = Task(
      id: 't2',
      title: 'Task Assigned to Other',
      projectId: 'p1',
      assignedTo: 'u2',
      status: 'todo',
      deadline: DateTime.now().add(const Duration(days: 1)),
    );

    mockTaskProvider.setTasks([task1, task2]);

    await tester.pumpWidget(createProjectTaskScreen());
    await tester.pumpAndSettle();

    // Member should see both tasks
    expect(find.text('Task Assigned to Me'), findsOneWidget);
    expect(find.text('Task Assigned to Other'), findsOneWidget);
    expect(find.textContaining('Hiển thị toàn bộ công việc trong dự án'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('F2. Manager can edit task details and reassign task to another project member', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;

    mockAuthProvider.setCurrentUser(managerUser);

    final project = ProjectModel(
      id: 'p1',
      name: 'Test Project',
      description: 'Desc',
      memberIds: ['mgr', 'u1', 'u2'],
    );
    mockProjectProvider.setProjects([project]);
    mockProjectProvider.setAllUsers([
      managerUser,
      UserModel(id: 'u1', name: 'Member 1', email: 'm1@test.com', role: 'member', password: ''),
      UserModel(id: 'u2', name: 'Member 2', email: 'm2@test.com', role: 'member', password: ''),
    ]);

    mockTaskProvider.setTasks([taskAssignedToMe]); // id: 't1', assignedTo: 'u1'

    await tester.pumpWidget(createTaskDetailScreen(taskAssignedToMe));
    await tester.pumpAndSettle();

    // Tap on Edit button
    final editBtn = find.byIcon(Icons.edit);
    expect(editBtn, findsOneWidget);
    await tester.tap(editBtn);
    await tester.pumpAndSettle();

    // Verify Edit Dialog shows up
    expect(find.text('Chỉnh sửa nhiệm vụ'), findsOneWidget);

    // Enter new title
    final titleField = find.widgetWithText(TextField, 'Tiêu đề');
    await tester.enterText(titleField, 'New Task Title');

    // Tap the dropdown to change assignee to Member 2
    final dropdown = find.byType(DropdownButtonFormField<String>);
    expect(dropdown, findsOneWidget);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Select Member 2
    final dropdownItem = find.text('Member 2').last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    // Tap Save button
    final saveBtn = find.text('Lưu');
    expect(saveBtn, findsOneWidget);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify taskProvider.editTask was called with correct values
    expect(mockTaskProvider.editedTask, isNotNull);
    expect(mockTaskProvider.editedTask!.title, 'New Task Title');
    expect(mockTaskProvider.editedTask!.assignedTo, 'u2');
    expect(mockTaskProvider.editedTask!.assigneeName, 'Member 2');

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('F3. Manager can approve and reject a task', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;

    mockAuthProvider.setCurrentUser(managerUser);
    mockTaskProvider.setTasks([taskReviewing]);

    await tester.pumpWidget(createTaskDetailScreen(taskReviewing));
    await tester.pumpAndSettle();

    // Verify buttons show
    final approveBtn = find.text('DUYỆT');
    final rejectBtn = find.text('Từ chối');
    expect(approveBtn, findsOneWidget);
    expect(rejectBtn, findsOneWidget);

    // Test Approve
    await tester.ensureVisible(approveBtn);
    await tester.tap(approveBtn);
    await tester.pumpAndSettle();

    expect(mockTaskProvider.approvedTaskId, 't2');

    // Reset screen and test Reject
    mockTaskProvider.approvedTaskId = null;
    mockTaskProvider.setTasks([taskReviewing]);
    await tester.pumpWidget(createTaskDetailScreen(taskReviewing));
    await tester.pumpAndSettle();

    final rejectBtnToTap = find.text('Từ chối');
    await tester.ensureVisible(rejectBtnToTap);
    await tester.tap(rejectBtnToTap);
    await tester.pumpAndSettle();

    // Dialog should open
    expect(find.text('Từ chối nhiệm vụ'), findsOneWidget);

    // Enter reason
    final reasonField = find.byType(TextField);
    expect(reasonField, findsOneWidget);
    await tester.enterText(reasonField, 'Need more changes');

    // Click confirm Reject button
    final confirmBtn = find.widgetWithText(ElevatedButton, 'Từ chối').last;
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(mockTaskProvider.rejectedTaskId, 't2');
    expect(mockTaskProvider.rejectReason, 'Need more changes');

    addTearDown(tester.view.resetPhysicalSize);
  });
}
