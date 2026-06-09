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

// Mocks
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
  @override
  bool get isLoading => false;
  
  @override
  List<ProjectModel> get projects => [];
  
  @override
  List<UserModel> get allUsers => [
    UserModel(id: 'u1', name: 'Member 1', email: 'm1@test.com', role: 'member', password: ''),
  ];
  
  @override
  Future<void> loadAllUsers() async {}

  @override
  Future<void> loadProjects(UserModel currentUser) async {}
}

class MockTaskProvider extends TaskProvider {
  List<Task> _tasks = [];
  String? updatedTaskId;
  String? updatedTaskStatus;
  String? deletedTaskId;
  
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
        ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
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
    
    expect(find.text('TỪ CHỐI'), findsOneWidget);
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
    
    expect(find.text('TỪ CHỐI'), findsNothing);
    expect(find.text('DUYỆT'), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
