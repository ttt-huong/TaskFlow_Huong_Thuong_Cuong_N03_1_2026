import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart'; // Đọc AppProvider để kiểm tra quyền Manager/Member
import 'project_task_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isManager = provider.isManager;

    // Dữ liệu mẫu danh sách dự án chuẩn theo demo
    final List<Map<String, dynamic>> projects = [
      {
        'title': 'App Flutter',
        'subtitle': 'Quản lý công việc nhóm',
        'todo': 2,
        'doing': 3,
        'done': 4,
        'progress': 0.65,
        'percent': '65%',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Báo cáo môn học',
        'subtitle': 'Tài liệu + slide thuyết trình',
        'todo': 4,
        'doing': 1,
        'done': 1,
        'progress': 0.30,
        'percent': '30%',
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'UI Design Sprint',
        'subtitle': 'Prototype giao diện',
        'todo': 0,
        'doing': 1,
        'done': 9,
        'progress': 0.90,
        'percent': '90%',
        'color': const Color(0xFF10B981),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dự án',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              isManager
                  ? '3 projects'
                  : '2 projects', // Phân quyền số lượng hiển thị
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          // FIX LỖI 1: Thêm nút Tạo dự án (+) màu tím chuẩn phân quyền Manager
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
                  onPressed: () {
                    // Chức năng tạo dự án mới (nếu cần phát triển sau)
                  },
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              isManager
                  ? 'Xin chào, Nguyen Van A 👑'
                  : 'Xin chào, Tran Thi B 👤',
              style: TextStyle(
                color: isManager ? const Color(0xFF8B5CF6) : Colors.blueAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách card dự án
            Expanded(
              child: ListView.builder(
                itemCount: isManager
                    ? projects.length
                    : 2, // Member chỉ thấy 2 cái đầu theo thiết kế
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return GestureDetector(
                    onTap: () {
                      // Click nhảy vào trang chi tiết công việc của dự án đó
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectTaskScreen(projectName: project['title']),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161926),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.03),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project['subtitle'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Thống kê số lượng trạng thái Dots inline
                          Row(
                            children: [
                              _buildStatDot(
                                Colors.redAccent,
                                '${project['todo']} todo',
                              ),
                              const SizedBox(width: 12),
                              _buildStatDot(
                                Colors.orangeAccent,
                                '${project['doing']} doing',
                              ),
                              const SizedBox(width: 12),
                              _buildStatDot(
                                Colors.greenAccent,
                                '${project['done']} done',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Thanh Progress bar kéo dài tinh tế theo bản web rộng
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: project['progress'],
                                    backgroundColor: const Color(0xFF1E2235),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      project['color'],
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                project['percent'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildStatDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
