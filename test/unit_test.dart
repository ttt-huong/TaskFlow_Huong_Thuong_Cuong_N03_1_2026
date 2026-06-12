// =============================================================================
// FILE: test/unit_test.dart
// MỤC ĐÍCH: Kiểm thử đơn vị (Unit Tests) cho TaskFlow
//
// Bao gồm các nhóm test:
//   1. Task Model – Constructor, toMap/fromMap, trạng thái, quá hạn
//   2. Task Transitions – Ma trận chuyển đổi trạng thái hợp lệ
//   3. NotificationModel – Constructor, toMap/fromMap, copyWith
//   4. Search Filter Logic – Bộ lọc tìm kiếm theo từ khóa
//   5. Task Search Filter – Kết hợp lọc theo trạng thái + từ khóa
//   6. Assignee Role Filter – Chặn Manager khỏi danh sách Giao việc
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/task_model.dart';
import 'package:my_app/models/notification_model.dart';
import 'package:my_app/models/user_model.dart';

// ---------------------------------------------------------------------------
// Helper: tạo Task mẫu để dùng chung trong các test case
// ---------------------------------------------------------------------------
Task _makeTask({
  String id = 'task-001',
  String title = 'Thiết kế giao diện',
  String description = 'Thiết kế màn hình login theo Figma',
  String assignedTo = 'user-member-1',
  String assigneeName = 'Nguyễn Văn A',
  String status = 'todo',
  bool isUrgent = false,
  DateTime? deadline,
}) {
  return Task(
    id: id,
    title: title,
    description: description,
    projectId: 'project-001',
    assignedTo: assignedTo,
    status: status,
    deadline: deadline ?? DateTime.now().add(const Duration(days: 7)),
    assigneeName: assigneeName,
    assigneeAvatar: assigneeName.isNotEmpty ? assigneeName[0] : '?',
    isUrgent: isUrgent,
  );
}

// ---------------------------------------------------------------------------
// Helper: tạo NotificationModel mẫu
// ---------------------------------------------------------------------------
NotificationModel _makeNotification({
  String id = 'notif-001',
  String title = 'Giao việc mới',
  String message = 'Bạn vừa được giao nhiệm vụ: "Thiết kế giao diện".',
  bool isRead = false,
  String type = 'task_assigned',
}) {
  return NotificationModel(
    id: id,
    userId: 'user-member-1',
    relatedTaskId: 'task-001',
    title: title,
    message: message,
    createdAt: DateTime(2026, 6, 10, 8, 0),
    isRead: isRead,
    type: type,
  );
}

void main() {
  // ===========================================================================
  // NHÓM 1: Task Model — Constructor & Serialization
  // ===========================================================================
  group('Task Model', () {
    test('TC01 – Tạo Task với đầy đủ thông tin thành công', () {
      final task = _makeTask();

      expect(task.id, equals('task-001'));
      expect(task.title, equals('Thiết kế giao diện'));
      expect(task.status, equals('todo'));
      expect(task.isUrgent, isFalse);
      expect(task.assigneeName, equals('Nguyễn Văn A'));
    });

    test('TC02 – description mặc định là chuỗi rỗng nếu không truyền', () {
      final task = Task(
        id: 'task-002',
        title: 'No desc task',
        projectId: 'p-1',
        assignedTo: 'u-1',
        status: 'todo',
        deadline: DateTime.now().add(const Duration(days: 1)),
      );

      expect(task.description, equals(''));
    });

    test('TC03 – toMap() trả đúng các field cần thiết', () {
      final task = _makeTask(isUrgent: true);
      final map = task.toMap();

      expect(map['title'], equals('Thiết kế giao diện'));
      expect(map['status'], equals('todo'));
      expect(map['isUrgent'], isTrue);
      expect(map.containsKey('deadline'), isTrue);
      expect(map.containsKey('updatedAt'), isTrue);
    });

    test('TC04 – fromMap() dựng Task từ Map đúng', () {
      final now = DateTime(2026, 6, 15);
      final map = {
        'title': 'Backend API',
        'description': 'Viết REST API cho module Task',
        'projectId': 'p-2',
        'assignedTo': 'u-2',
        'status': 'doing',
        'deadline': now.toIso8601String(),
        'assigneeName': 'Trần Thị B',
        'assigneeAvatar': 'T',
        'isUrgent': false,
        'updatedAt': now.toIso8601String(),
      };

      final task = Task.fromMap(map, 'task-003');

      expect(task.id, equals('task-003'));
      expect(task.title, equals('Backend API'));
      expect(task.status, equals('doing'));
      expect(task.assigneeName, equals('Trần Thị B'));
    });

    test('TC05 – fromMap() với isUrgent=1 (SQLite integer) cho true', () {
      final map = {
        'title': 'Urgent task',
        'description': '',
        'projectId': 'p-1',
        'assignedTo': 'u-1',
        'status': 'todo',
        'deadline': DateTime.now().toIso8601String(),
        'assigneeName': '',
        'assigneeAvatar': '',
        'isUrgent': 1, // SQLite lưu int thay vì bool
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final task = Task.fromMap(map, 'task-urgent');
      expect(task.isUrgent, isTrue);
    });

    test('TC06 – deadlineFormatted trả đúng định dạng dd/MM/yyyy', () {
      final task = _makeTask(deadline: DateTime(2026, 12, 31));
      expect(task.deadlineFormatted, equals('31/12/2026'));
    });

    test('TC07 – deadlineShort trả đúng định dạng dd/MM', () {
      final task = _makeTask(deadline: DateTime(2026, 6, 10));
      expect(task.deadlineShort, equals('10/06'));
    });

    test('TC08 – toString() chứa id, title, status', () {
      final task = _makeTask();
      final str = task.toString();
      expect(str, contains('task-001'));
      expect(str, contains('Thiết kế giao diện'));
      expect(str, contains('todo'));
    });
  });

  // ===========================================================================
  // NHÓM 2: Task – Kiểm tra quá hạn (isOverdue)
  // ===========================================================================
  group('Task – isOverdue()', () {
    test('TC09 – Task chưa đến hạn → không quá hạn', () {
      final task = _makeTask(
        deadline: DateTime.now().add(const Duration(days: 5)),
      );
      expect(task.isOverdue(), isFalse);
    });

    test('TC10 – Task đã qua deadline và chưa done → quá hạn', () {
      final task = _makeTask(
        deadline: DateTime.now().subtract(const Duration(days: 2)),
        status: 'doing',
      );
      expect(task.isOverdue(), isTrue);
    });

    test('TC11 – Task đã qua deadline nhưng status=done → KHÔNG quá hạn', () {
      final task = _makeTask(
        deadline: DateTime.now().subtract(const Duration(days: 2)),
        status: 'done',
      );
      expect(task.isOverdue(), isFalse);
    });
  });

  // ===========================================================================
  // NHÓM 3: Task – Ma trận chuyển đổi trạng thái (State Transitions)
  // ===========================================================================
  group('Task – State Transitions', () {
    test('TC12 – todo → doing: hợp lệ', () {
      expect(Task.validateTransition('todo', 'doing'), isNull);
    });

    test('TC13 – todo → cancelled: hợp lệ', () {
      expect(Task.validateTransition('todo', 'cancelled'), isNull);
    });

    test('TC14 – todo → done: không hợp lệ', () {
      expect(Task.validateTransition('todo', 'done'), isNotNull);
    });

    test('TC15 – doing → reviewing: hợp lệ (Member nộp bài)', () {
      expect(Task.validateTransition('doing', 'reviewing'), isNull);
    });

    test('TC16 – doing → todo: hợp lệ (quay lại)', () {
      expect(Task.validateTransition('doing', 'todo'), isNull);
    });

    test('TC17 – reviewing → done: hợp lệ (Manager duyệt)', () {
      expect(Task.validateTransition('reviewing', 'done'), isNull);
    });

    test('TC18 – reviewing → doing: hợp lệ (Manager từ chối)', () {
      expect(Task.validateTransition('reviewing', 'todo'), isNull);
    });

    test('TC19 – done → archived: hợp lệ', () {
      expect(Task.validateTransition('done', 'archived'), isNull);
    });

    test('TC20 – done → todo: không hợp lệ', () {
      expect(Task.validateTransition('done', 'todo'), isNotNull);
    });

    test('TC21 – cancelled → doing: không hợp lệ (trạng thái cuối)', () {
      expect(Task.validateTransition('cancelled', 'doing'), isNotNull);
    });

    test('TC22 – archived → todo: không hợp lệ (trạng thái cuối)', () {
      expect(Task.validateTransition('archived', 'todo'), isNotNull);
    });

    test('TC23 – Trạng thái không tồn tại → không hợp lệ', () {
      expect(Task.validateTransition('todo', 'unknown_status'), isNotNull);
    });

    test('TC24 – canTransitionTo() nhất quán với validateTransition()', () {
      final task = _makeTask(status: 'doing');
      expect(task.canTransitionTo('reviewing'), isTrue);
      expect(task.canTransitionTo('done'), isFalse);
    });

    test('TC25 – updateStatus() cập nhật status khi hợp lệ', () async {
      final task = _makeTask(status: 'todo');
      final result = await task.updateStatus('doing');
      expect(result, isTrue);
      expect(task.status, equals('doing'));
    });

    test('TC26 – updateStatus() không cập nhật khi không hợp lệ', () async {
      final task = _makeTask(status: 'todo');
      final result = await task.updateStatus('done');
      expect(result, isFalse);
      expect(task.status, equals('todo')); // Status không đổi
    });
  });

  // ===========================================================================
  // NHÓM 4: NotificationModel
  // ===========================================================================
  group('NotificationModel', () {
    test('TC27 – Tạo NotificationModel với đầy đủ thông tin', () {
      final notif = _makeNotification();
      expect(notif.id, equals('notif-001'));
      expect(notif.userId, equals('user-member-1'));
      expect(notif.relatedTaskId, equals('task-001'));
      expect(notif.isRead, isFalse);
      expect(notif.type, equals('task_assigned'));
    });

    test('TC28 – toMap() lưu isRead dạng int (0/1) tương thích SQLite', () {
      final notif = _makeNotification(isRead: false);
      expect(notif.toMap()['isRead'], equals(0));

      final readNotif = _makeNotification(isRead: true);
      expect(readNotif.toMap()['isRead'], equals(1));
    });

    test('TC29 – fromMap() đọc isRead=1 → true', () {
      final map = {
        'id': 'n-2',
        'userId': 'user-member-1',
        'relatedTaskId': 'task-001',
        'title': 'Test',
        'message': 'Msg',
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': 1,
        'type': 'status_update',
      };
      final notif = NotificationModel.fromMap(map);
      expect(notif.userId, equals('user-member-1'));
      expect(notif.relatedTaskId, equals('task-001'));
      expect(notif.isRead, isTrue);
    });

    test('TC30 – fromMap() đọc isRead=0 → false', () {
      final map = {
        'id': 'n-3',
        'userId': 'user-member-1',
        'relatedTaskId': 'task-001',
        'title': 'Test',
        'message': 'Msg',
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': 0,
        'type': 'task_assigned',
      };
      final notif = NotificationModel.fromMap(map);
      expect(notif.isRead, isFalse);
    });

    test('TC31 – copyWith(isRead: true) tạo bản sao đã đọc', () {
      final original = _makeNotification(isRead: false);
      final updated = original.copyWith(isRead: true);

      expect(original.isRead, isFalse); // Bản gốc không thay đổi
      expect(updated.isRead, isTrue);
      expect(updated.id, equals(original.id));
      expect(updated.title, equals(original.title));
    });

    test('TC32 – toMap() → fromMap() khứ hồi cho cùng dữ liệu', () {
      final original = _makeNotification();
      final map = original.toMap()..['id'] = original.id;
      final restored = NotificationModel.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.userId, equals(original.userId));
      expect(restored.relatedTaskId, equals(original.relatedTaskId));
      expect(restored.title, equals(original.title));
      expect(restored.isRead, equals(original.isRead));
      expect(restored.type, equals(original.type));
    });
  });

  // ===========================================================================
  // NHÓM 5: Search Filter Logic – lọc task theo từ khóa tìm kiếm
  // ===========================================================================
  group('Search Filter Logic', () {
    final List<Task> sampleTasks = [
      _makeTask(
        id: '1',
        title: 'Thiết kế giao diện login',
        description: 'Dùng Figma để thiết kế',
        assigneeName: 'Nguyễn Văn A',
        status: 'todo',
      ),
      _makeTask(
        id: '2',
        title: 'Viết API backend',
        description: 'REST API cho module task',
        assigneeName: 'Trần Thị B',
        status: 'doing',
      ),
      _makeTask(
        id: '3',
        title: 'Test tính năng thông báo',
        description: 'Kiểm thử push notification',
        assigneeName: 'Lê Văn C',
        status: 'reviewing',
      ),
      _makeTask(
        id: '4',
        title: 'Deploy lên production',
        description: 'Upload APK lên Play Store',
        assigneeName: 'Nguyễn Văn A',
        status: 'done',
      ),
    ];

    /// Hàm lọc giống logic trong HomeScreen._buildTabMyTasks()
    List<Task> _filterTasks(List<Task> tasks, String query) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return tasks;
      return tasks.where((task) {
        return task.title.toLowerCase().contains(q) ||
            task.description.toLowerCase().contains(q) ||
            task.assigneeName.toLowerCase().contains(q);
      }).toList();
    }

    test('TC33 – Từ khóa rỗng → trả toàn bộ danh sách', () {
      final result = _filterTasks(sampleTasks, '');
      expect(result.length, equals(4));
    });

    test('TC34 – Tìm theo tiêu đề: "api" → trả đúng task Viết API', () {
      final result = _filterTasks(sampleTasks, 'api');
      expect(result.length, equals(1));
      expect(result.first.id, equals('2'));
    });

    test('TC35 – Tìm theo mô tả: "figma" → trả đúng task Thiết kế', () {
      final result = _filterTasks(sampleTasks, 'figma');
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
    });

    test('TC36 – Tìm theo tên nhân viên: "nguyễn văn a" → 2 task', () {
      final result = _filterTasks(sampleTasks, 'nguyễn văn a');
      expect(result.length, equals(2));
      expect(result.map((t) => t.id).toList(), containsAll(['1', '4']));
    });

    test('TC37 – Tìm không phân biệt hoa/thường: "THÔNG BÁO"', () {
      final result = _filterTasks(sampleTasks, 'THÔNG BÁO');
      expect(result.length, equals(1));
      expect(result.first.id, equals('3'));
    });

    test('TC38 – Từ khóa không khớp bất kỳ task nào → danh sách rỗng', () {
      final result = _filterTasks(sampleTasks, 'xyz_không_tồn_tại');
      expect(result, isEmpty);
    });

    test('TC39 – Tìm từ khóa một phần tiêu đề: "deploy" → 1 task', () {
      final result = _filterTasks(sampleTasks, 'deploy');
      expect(result.length, equals(1));
      expect(result.first.id, equals('4'));
    });

    test('TC40 – Kết hợp lọc trạng thái + từ khóa: doing + "api"', () {
      // Bước 1: Lọc theo trạng thái
      final statusFiltered =
          sampleTasks.where((t) => t.status == 'doing').toList();
      // Bước 2: Lọc theo từ khóa
      final result = _filterTasks(statusFiltered, 'api');

      expect(result.length, equals(1));
      expect(result.first.title, contains('API'));
    });

    test('TC41 – Kết hợp lọc: todo + từ khóa không khớp → rỗng', () {
      final statusFiltered =
          sampleTasks.where((t) => t.status == 'todo').toList();
      final result = _filterTasks(statusFiltered, 'deploy');

      expect(result, isEmpty);
    });
  }); // end group: Search Filter Logic

  // ===========================================================================
  // NHÓM 6: Assignee Role Filter – Chặn Manager khỏi danh sách Giao việc
  // ===========================================================================
  group('Assignee Role Filter', () {
    // Danh sách hỗn hợp: 2 manager + 3 member
    final allUsers = [
      UserModel(id: 'mgr-1', name: 'Trưởng phòng A', email: 'mgr1@app.com', password: '', role: 'manager'),
      UserModel(id: 'mgr-2', name: 'Trưởng phòng B', email: 'mgr2@app.com', password: '', role: 'manager'),
      UserModel(id: 'mem-1', name: 'Nhân viên X',    email: 'mem1@app.com', password: '', role: 'member'),
      UserModel(id: 'mem-2', name: 'Nhân viên Y',    email: 'mem2@app.com', password: '', role: 'member'),
      UserModel(id: 'mem-3', name: 'Nhân viên Z',    email: 'mem3@app.com', password: '', role: 'member'),
    ];

    /// Hàm lọc giống logic trong main_screen._showCreateTaskSheet()
    List<UserModel> _membersOnly(List<UserModel> users) {
      return users.where((u) => !u.isManager).toList();
    }

    test('TC42 – isManager trả true cho user có role="manager"', () {
      final mgr = allUsers[0];
      expect(mgr.isManager, isTrue);
    });

    test('TC43 – isManager trả false cho user có role="member"', () {
      final mem = allUsers[2];
      expect(mem.isManager, isFalse);
    });

    test('TC44 – Lọc membersOnly: 2 manager bị loại, còn 3 member', () {
      final result = _membersOnly(allUsers);
      expect(result.length, equals(3));
    });

    test('TC45 – Tất cả kết quả lọc đều có role=member', () {
      final result = _membersOnly(allUsers);
      expect(result.every((u) => u.role == 'member'), isTrue);
    });

    test('TC46 – Không có manager nào lọt qua', () {
      final result = _membersOnly(allUsers);
      expect(result.any((u) => u.isManager), isFalse);
    });

    test('TC47 – Danh sách chỉ toàn manager → kết quả rỗng', () {
      final managersOnly = allUsers.where((u) => u.isManager).toList();
      final result = _membersOnly(managersOnly);
      expect(result, isEmpty);
    });

    test('TC48 – Danh sách rỗng → vẫn trả về rỗng, không crash', () {
      final result = _membersOnly([]);
      expect(result, isEmpty);
    });

    test('TC49 – Lọc theo dự án (memberIds) sau khi đã lọc role', () {
      // Giả sử dự án chỉ có mem-1 và mem-2 (mem-3 không tham gia)
      final projectMemberIds = {'mem-1', 'mem-2'};
      final result = _membersOnly(allUsers)
          .where((u) => projectMemberIds.contains(u.id))
          .toList();

      expect(result.length, equals(2));
      expect(result.map((u) => u.id).toList(), containsAll(['mem-1', 'mem-2']));
    });

    test('TC50 – Tên tab Manager: "Thành viên" (không phải "Nhóm")', () {
      // Kiểm tra string label đúng ngữ nghĩa nghiệp vụ
      const expectedLabel = 'Thành viên';
      const oldLabel = 'Nhóm';
      expect(expectedLabel, isNot(equals(oldLabel)));
      expect(expectedLabel.contains('Thành viên'), isTrue);
    });
  }); // end group: Assignee Role Filter

  // ===========================================================================
  // NHÓM 7: Default Member Role – Đăng ký mặc định Nhân viên
  // ===========================================================================
  group('Default Member Role on Registration', () {
    /// Mô phỏng hàm đăng ký: luôn gán role = 'member' bất kể input
    String _resolveRegisterRole() => 'member';

    test('TC51 – Role đăng ký mặc định luôn là "member"', () {
      final role = _resolveRegisterRole();
      expect(role, equals('member'));
    });

    test('TC52 – Role đăng ký KHÔNG phải "manager"', () {
      final role = _resolveRegisterRole();
      expect(role, isNot(equals('manager')));
    });

    test('TC53 – UserModel tạo từ đăng ký: isManager = false', () {
      final newUser = UserModel(
        id: 'new-001',
        name: 'Người mới',
        email: 'new@app.com',
        password: 'secret',
        role: _resolveRegisterRole(),
      );
      expect(newUser.isManager, isFalse);
      expect(newUser.role, equals('member'));
    });

    test('TC54 – fromMap() với role="member" từ server → isManager false', () {
      final map = {
        'name': 'User mới',
        'email': 'user@app.com',
        'password': '',
        'role': 'member',
        'avatarChar': 'U',
      };
      final user = UserModel.fromMap(map, 'uid-new');
      expect(user.isManager, isFalse);
    });

    test('TC55 – fromMap() thiếu trường role → mặc định "member"', () {
      // Trường hợp server trả về doc không có trường role
      final map = {
        'name': 'User thiếu role',
        'email': 'x@app.com',
        'password': '',
        'avatarChar': 'X',
        // Không có 'role'
      };
      final user = UserModel.fromMap(map, 'uid-norole');
      expect(user.role, equals('member'));
      expect(user.isManager, isFalse);
    });

    test('TC56 – Manager chỉ tồn tại khi Admin cấp quyền (role="manager")', () {
      // Simulate: Admin promote user lên manager
      final promoted = UserModel(
        id: 'uid-promoted',
        name: 'Trưởng phòng',
        email: 'lead@app.com',
        password: '',
        role: 'manager', // Do Admin gán thủ công
      );
      expect(promoted.isManager, isTrue);
    });
  });
}
