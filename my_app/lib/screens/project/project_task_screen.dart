import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/task_model.dart';

class ProjectTaskScreen extends StatefulWidget {
  final String projectName;
  const ProjectTaskScreen({Key? key, required this.projectName})
    : super(key: key);

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isManager = provider.isManager;

<<<<<<< HEAD
    List<Task> displayedTasks = _mockTasks.where((task) {
      if (!isManager && task.assignedTo != 'b') return false;
=======
    // Bộ lọc lọc task theo Tab và theo phân quyền Vai trò
    List<Task> displayedTasks = _mockTasks.where((task) {
      if (!isManager && task.assignedTo != 'b')
        return false; // Member chỉ thấy task của mình
>>>>>>> 868b09a (update)

      if (_selectedTab == 'Todo' && task.status != 'todo') return false;
      if (_selectedTab == 'Doing' && task.status != 'doing') return false;
      if (_selectedTab == 'Review' && task.status != 'reviewing') return false;
      if (_selectedTab == 'Done' && task.status != 'done') return false;

      if (isManager && _selectedMemberFilter != 'Tất cả thành viên') {
        if (_selectedMemberFilter == 'Nguyen Van A' && task.assignedTo != 'a')
          return false;
        if (_selectedMemberFilter == 'Tran Thi B' && task.assignedTo != 'b')
          return false;
        if (_selectedMemberFilter == 'Le Van C' && task.assignedTo != 'c')
          return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
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
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            Text(
              isManager
                  ? '${_mockTasks.length} tasks'
                  : '${_mockTasks.where((t) => t.assignedTo == 'b').length} tasks của bạn',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items:
                      [
                        'Tất cả thành viên',
                        'Nguyen Van A',
                        'Tran Thi B',
                        'Le Van C',
                      ].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedMemberFilter = val!),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: ListView.builder(
                itemCount: displayedTasks.length,
                itemBuilder: (context, index) {
                  final task = displayedTasks[index];
                  return _buildTaskCard(task, isManager);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, bool isManager) {
    Color statusColor = Colors.grey;
    if (task.status == 'todo') statusColor = Colors.redAccent;
    if (task.status == 'doing') statusColor = Colors.orangeAccent;
    if (task.status == 'reviewing') statusColor = Colors.blueAccent;
    if (task.status == 'done') statusColor = Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161926),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              task.assignedTo.toUpperCase(),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
