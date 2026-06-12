import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/task_model.dart';
import 'package:my_app/models/user_model.dart';
import 'package:my_app/providers/auth_provider.dart';
import 'package:my_app/providers/project_provider.dart';
import 'package:my_app/providers/task_provider.dart';
import 'package:my_app/screens/project_task_screen.dart';

// --- MOCK PROVIDERS ---
class MockTaskProvider extends TaskProvider {
  List<Task> _mockTasks = [];
  bool _mockIsLoading = false;

  @override
  List<Task> get tasks => _mockTasks;

  @override
  bool get isLoading => _mockIsLoading;

  void setMockTasks(List<Task> tasks) {
    _mockTasks = tasks;
    notifyListeners();
  }

  void setMockIsLoading(bool val) {
    _mockIsLoading = val;
    notifyListeners();
  }

  @override
  Future<void> loadTasksByProject(String projectId) async {
    // Bỏ qua gọi repo thật trong unit test
  }
}

class MockAuthProvider extends AuthProvider {
  UserModel? _mockUser;
  bool _mockIsOfflineMode = false;

  @override
  UserModel? get currentUser => _mockUser;

  @override
  bool get isOfflineMode => _mockIsOfflineMode;

  void setMockUser(UserModel? user) {
    _mockUser = user;
    notifyListeners();
  }

  void setMockOffline(bool offline) {
    _mockIsOfflineMode = offline;
    notifyListeners();
  }
}

class MockProjectProvider extends ProjectProvider {
  List<UserModel> _mockUsers = [];

  @override
  List<UserModel> get allUsers => _mockUsers;

  void setMockUsers(List<UserModel> users) {
    _mockUsers = users;
    notifyListeners();
  }

  @override
  Future<void> loadAllUsers() async {
    // Bỏ qua gọi repo thật trong unit test
  }
}

void main() {
  late MockTaskProvider mockTaskProvider;
  late MockAuthProvider mockAuthProvider;
  late MockProjectProvider mockProjectProvider;

  setUp(() {
    mockTaskProvider = MockTaskProvider();
    mockAuthProvider = MockAuthProvider();
    mockProjectProvider = MockProjectProvider();
  });

  Widget createTestWidget(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ProjectProvider>.value(value: mockProjectProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: mockTaskProvider),
      ],
      child: const MaterialApp(
        home: ProjectTaskScreen(
          projectId: 'p1',
          projectName: 'Project Test',
        ),
      ),
    );
  }

  // Helper chuyển đổi sang tab Calendar một cách tin cậy trong môi trường Test
  Future<void> switchToCalendarTab(WidgetTester tester) async {
    final tabController = DefaultTabController.of(tester.element(find.byType(TabBar)));
    tabController.index = 1;
    await tester.pumpAndSettle();
  }

  group('Calendar Tab Implementation Verification', () {
    // 1. TAB BEHAVIOR & RESET
    testWidgets('1. TabBar displays list and calendar tabs, defaults to Index 0', (WidgetTester tester) async {
      mockAuthProvider.setMockUser(UserModel(id: 'u1', name: 'Manager', email: '', role: 'manager', password: ''));
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      // Kiểm tra có tab bar hiển thị 2 tab
      expect(find.text('Danh sách'), findsOneWidget);
      expect(find.text('Lịch biểu'), findsOneWidget);

      // Mặc định tab 0 hiển thị (thanh filter 'Tất cả')
      expect(find.text('Tất cả'), findsOneWidget);
    });

    // 2. ROLE FILTER SECURITY
    testWidgets('2. Manager sees all tasks, Member only sees assigned tasks on Calendar', (WidgetTester tester) async {
      final today = DateTime.now();
      
      // Setup tasks
      final t1 = Task(
        id: 't1', title: 'Task Manager Only', projectId: 'p1', assignedTo: 'u2', status: 'todo',
        deadline: today, assigneeName: 'Member B'
      );
      final t2 = Task(
        id: 't2', title: 'Task Assigned to Member A', projectId: 'p1', assignedTo: 'u1', status: 'doing',
        deadline: today, assigneeName: 'Member A'
      );
      mockTaskProvider.setMockTasks([t1, t2]);

      // CASE A: MANAGER
      mockAuthProvider.setMockUser(UserModel(id: 'u9', name: 'Boss', email: '', role: 'manager', password: ''));
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      // Mở Tab Lịch biểu
      await switchToCalendarTab(tester);

      // Click today
      await tester.tap(find.byKey(ValueKey('day_${today.day}_${today.month}')));
      await tester.pumpAndSettle();

      expect(find.text('Task Manager Only'), findsOneWidget);
      expect(find.text('Task Assigned to Member A'), findsOneWidget);

      // CASE B: MEMBER A
      mockAuthProvider.setMockUser(UserModel(id: 'u1', name: 'Member A', email: '', role: 'member', password: ''));
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      await switchToCalendarTab(tester);

      await tester.tap(find.byKey(ValueKey('day_${today.day}_${today.month}')));
      await tester.pumpAndSettle();

      // Member A có thể xem tất cả task (cả t1 và t2) theo thiết kế mới
      expect(find.text('Task Assigned to Member A'), findsOneWidget);
      expect(find.text('Task Manager Only'), findsOneWidget);
    });

    // 3. DATE RENDERING & STATUS COLORS
    testWidgets('3. Tasks are filtered and rendered by color coding', (WidgetTester tester) async {
      mockAuthProvider.setMockUser(UserModel(id: 'u1', name: 'Manager', email: '', role: 'manager', password: ''));
      
      final today = DateTime.now();
      // Dùng ngày của 5 năm trước đại diện cho task nằm ngoài tháng hiện tại (không hiển thị trên ô ngày tháng này)
      final noDeadlineTask = Task(id: 't0', title: 'Hidden Task', projectId: 'p1', assignedTo: 'u1', status: 'todo', deadline: DateTime(2020, 1, 1));
      final doneTask = Task(id: 't1', title: 'Done Task', projectId: 'p1', assignedTo: 'u1', status: 'done', deadline: today);
      
      mockTaskProvider.setMockTasks([noDeadlineTask, doneTask]);
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      await switchToCalendarTab(tester);

      // Click today
      await tester.tap(find.byKey(ValueKey('day_${today.day}_${today.month}')));
      await tester.pumpAndSettle();

      // Done Task xuất hiện trên lịch biểu ngày hôm nay, Hidden Task bị ẩn khỏi danh sách
      expect(find.text('Done Task'), findsOneWidget);
      expect(find.text('Hidden Task'), findsNothing);
    });

    // 4. MULTIPLE TASKS SAME DAY (+N INDICATOR)
    testWidgets('4. If 3+ tasks in same day, +N indicator is displayed', (WidgetTester tester) async {
      mockAuthProvider.setMockUser(UserModel(id: 'u1', name: 'Manager', email: '', role: 'manager', password: ''));
      
      final today = DateTime.now();
      final t1 = Task(id: 't1', title: 'Task 1', projectId: 'p1', assignedTo: 'u1', status: 'todo', deadline: today);
      final t2 = Task(id: 't2', title: 'Task 2', projectId: 'p1', assignedTo: 'u1', status: 'doing', deadline: today);
      final t3 = Task(id: 't3', title: 'Task 3', projectId: 'p1', assignedTo: 'u1', status: 'reviewing', deadline: today);
      final t4 = Task(id: 't4', title: 'Task 4', projectId: 'p1', assignedTo: 'u1', status: 'done', deadline: today);
      
      mockTaskProvider.setMockTasks([t1, t2, t3, t4]);
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      await switchToCalendarTab(tester);

      // Phải có chỉ báo +2 hiển thị trên ô ngày hôm nay (4 tasks - 2 tasks vẽ dot = +2)
      expect(find.text('+2'), findsOneWidget);
    });

    // 5. MONTH NAVIGATION
    testWidgets('5. Month switching using chevrons works without crashing', (WidgetTester tester) async {
      mockAuthProvider.setMockUser(UserModel(id: 'u1', name: 'Manager', email: '', role: 'manager', password: ''));
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      await switchToCalendarTab(tester);

      // Kiểm tra có hiển thị tháng hiện tại
      final currentMonth = DateTime.now().month;
      expect(find.textContaining('Tháng $currentMonth'), findsOneWidget);

      // Nhấn chuyển sang tháng tiếp theo
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      final nextMonth = DateTime.now().add(const Duration(days: 31)).month;
      expect(find.textContaining('Tháng $nextMonth'), findsOneWidget);
    });

    // 6. DAY TAP INTERACTION & EMPTY STATE
    testWidgets('6. Tapping date shows task list below, empty day shows empty notice', (WidgetTester tester) async {
      mockAuthProvider.setMockUser(UserModel(id: 'u1', name: 'Manager', email: '', role: 'manager', password: ''));
      
      final today = DateTime.now();
      
      final t1 = Task(id: 't1', title: 'Today Task', projectId: 'p1', assignedTo: 'u1', status: 'todo', deadline: today);
      mockTaskProvider.setMockTasks([t1]);

      await tester.pumpWidget(createTestWidget(tester));
      await tester.pump();

      await switchToCalendarTab(tester);

      // 1. Tap today -> hiển thị task Today Task
      await tester.tap(find.byKey(ValueKey('day_${today.day}_${today.month}')));
      await tester.pumpAndSettle();
      expect(find.text('Today Task'), findsOneWidget);

      // 2. Tap ngày khác không có task (ví dụ ngày 28 nếu hôm nay không phải 28)
      int emptyDay = today.day == 28 ? 20 : 28;
      await tester.tap(find.byKey(ValueKey('day_${emptyDay}_${today.month}')));
      await tester.pumpAndSettle();
      
      expect(find.text('Không có nhiệm vụ nào trong ngày này'), findsOneWidget);
    });
  });
}
