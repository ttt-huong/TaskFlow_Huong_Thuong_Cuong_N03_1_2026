import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart'; // Đọc AppProvider để kiểm tra quyền Manager/Member

class ProjectTaskScreen extends StatefulWidget {
  final String projectName;
  const ProjectTaskScreen({Key? key, required this.projectName})
    : super(key: key);

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
<<<<<<< HEAD
  String _selectedTab = 'Tất cả';
  String _selectedMemberFilter = 'Tất cả thành viên';

<<<<<<< HEAD
=======
  // Dữ liệu mẫu khởi tạo khớp 100% với model Task gốc của nhóm bạn
>>>>>>> 868b09a (update)
  final List<Task> _mockTasks = [
    Task(
      id: '1',
      title: 'Viết Firebase Auth',
      description: 'Tích hợp đăng nhập',
      projectId: '1',
      assignedTo: 'b',
      status: 'reviewing',
      deadline: DateTime(2026, 4, 20),
    ),
    Task(
      id: '2',
      title: 'Thiết kế UI Login Screen',
      description: 'Giao diện Figma',
      projectId: '1',
      assignedTo: 'b',
      status: 'doing',
      deadline: DateTime(2026, 4, 30),
    ),
    Task(
      id: '3',
      title: 'Project List Screen',
      description: 'Danh sách dự án',
      projectId: '1',
      assignedTo: 'b',
      status: 'todo',
      deadline: DateTime(2026, 5, 5),
    ),
    Task(
      id: '4',
      title: 'Thiết kế UI Login',
      description: 'Bản vẽ nháp',
      projectId: '1',
      assignedTo: 'c',
      status: 'doing',
      deadline: DateTime(2026, 4, 20),
    ),
    Task(
      id: '5',
      title: 'Viết báo cáo chương 2',
      description: 'Báo cáo tiến độ',
      projectId: '1',
      assignedTo: 'a',
      status: 'todo',
      deadline: DateTime(2026, 4, 22),
    ),
    Task(
      id: '6',
      title: 'Tạo mock data',
      description: 'Dữ liệu mẫu',
      projectId: '1',
      assignedTo: 'b',
      status: 'done',
      deadline: DateTime(2026, 4, 15),
    ),
  ];
=======
  String _selectedFilter = 'Tất cả';
>>>>>>> 1a0af3f (Feat: Hoan thanh code phan quyen man hinh Project)

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isManager = provider.isManager;

<<<<<<< HEAD
<<<<<<< HEAD
    List<Task> displayedTasks = _mockTasks.where((task) {
      if (!isManager && task.assignedTo != 'b') return false;
=======
    // Bộ lọc lọc task theo Tab và theo phân quyền Vai trò
    List<Task> displayedTasks = _mockTasks.where((task) {
      if (!isManager && task.assignedTo != 'b')
        return false; // Member chỉ thấy task của mình
>>>>>>> 868b09a (update)
=======
    // Danh sách data mẫu phục vụ lọc tab
    final List<Map<String, dynamic>> mockTasks = [
      {
        'title': 'Viết Firebase Auth',
        'status': 'REVIEWING',
        'displayStatus': 'Review',
        'statusColor': Colors.blueAccent,
        'user': 'B',
        'isManagerOnly': false,
      },
      {
        'title': 'Thiết kế UI Login Screen',
        'status': 'DOING',
        'displayStatus': 'Doing',
        'statusColor': Colors.orangeAccent,
        'user': 'B',
        'isManagerOnly': false,
      },
      {
        'title': 'Project List Screen',
        'status': 'TODO',
        'displayStatus': 'Todo',
        'statusColor': Colors.redAccent,
        'user': 'B',
        'isManagerOnly': false,
      },
      {
        'title': 'Thiết kế UI Login',
        'status': 'DOING',
        'displayStatus': 'Doing',
        'statusColor': Colors.orangeAccent,
        'user': 'C',
        'isManagerOnly': true,
      },
      {
        'title': 'Viết báo cáo chương 2',
        'status': 'TODO',
        'displayStatus': 'Todo',
        'statusColor': Colors.redAccent,
        'user': 'A',
        'isManagerOnly': true,
      },
    ];
>>>>>>> 1a0af3f (Feat: Hoan thanh code phan quyen man hinh Project)

    // Lọc theo vai trò: Quyền Member chỉ thấy task của chính họ (B)
    List<Map<String, dynamic>> roleFiltered = isManager
        ? mockTasks
        : mockTasks.where((task) => task['isManagerOnly'] == false).toList();

    // Lọc tiếp theo các tab "Todo", "Doing", "Review" đang click chọn trên UI
    List<Map<String, dynamic>> finalFilteredTasks = roleFiltered;
    if (_selectedFilter != 'Tất cả') {
      finalFilteredTasks = roleFiltered
          .where((task) => task['displayStatus'] == _selectedFilter)
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              isManager
                  ? '${mockTasks.length} tasks'
                  : '${roleFiltered.length} tasks của bạn',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            const SizedBox(height: 16),
<<<<<<< HEAD
=======
            // Thanh chuyển đổi Tab trạng thái task dạng cuộn ngang mượt mà
>>>>>>> 868b09a (update)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((
                  tab,
                ) {
                  final isSelected = _selectedTab == tab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

<<<<<<< HEAD
=======
            // Dropdown lọc thành viên chỉ xuất hiện nếu là Manager
>>>>>>> 868b09a (update)
            if (isManager) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButton<String>(
                  value: _selectedMemberFilter,
                  dropdownColor: const Color(0xFF1E2235),
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
=======
            // Thanh Filter ngang điều hướng trạng thái
            Row(
              children: ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((
                tab,
              ) {
                final isSelected = _selectedFilter == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF1E2235),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
>>>>>>> 1a0af3f (Feat: Hoan thanh code phan quyen man hinh Project)
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Dòng text phân quyền phụ ngay bên dưới thanh bộ lọc
            isManager
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2235),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tất cả thành viên',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ],
                    ),
                  )
                : const Text(
                    'Chỉ hiển thị task được gán cho bạn',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
            const SizedBox(height: 20),

            // Danh sách Task Card công việc
            Expanded(
              child: finalFilteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có công việc nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: finalFilteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = finalFilteredTasks[index];
                        final bool isReviewing = task['status'] == 'REVIEWING';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161926),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.01),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: task['statusColor'] as Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (task['statusColor'] as Color)
                                                    .withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            task['status'] as String,
                                            style: TextStyle(
                                              color:
                                                  task['statusColor'] as Color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // FIX LỖI 2: Đã thêm thành công 2 nút Duyệt / Từ chối thông minh inline cho Manager
                                        if (isManager && isReviewing) ...[
                                          _buildActionButton(
                                            'Từ chối',
                                            Colors.orangeAccent,
                                          ),
                                          const SizedBox(width: 6),
                                          _buildActionButton(
                                            'Duyệt',
                                            Colors.greenAccent,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue.withOpacity(0.15),
                                child: Text(
                                  task['user'] as String,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
