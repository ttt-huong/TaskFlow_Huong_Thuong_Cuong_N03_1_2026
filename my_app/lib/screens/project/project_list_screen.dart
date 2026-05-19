import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/project_model.dart';
import 'project_task_screen.dart'; // Chuyển tiếp sang màn hình Task con

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isManager = provider.isManager;

    // Dữ liệu mẫu hiển thị danh sách dự án
    final List<ProjectModel> mockProjects = [
      ProjectModel(
        id: '1',
        name: 'App Flutter',
        description: 'Quản lý công việc nhóm',
        memberIds: ['a', 'b'],
        todoCount: 2,
        doingCount: 3,
        doneCount: 4,
        progress: 0.65,
      ),
      ProjectModel(
        id: '2',
        name: 'Báo cáo môn học',
        description: 'Tài liệu + slide thuyết trình',
        memberIds: ['a', 'c'],
        todoCount: 4,
        doingCount: 1,
        doneCount: 1,
        progress: 0.30,
      ),
      ProjectModel(
        id: '3',
        name: 'UI Design Sprint',
        description: 'Prototype giao diện',
        memberIds: ['a'],
        todoCount: 0,
        doingCount: 1,
        doneCount: 9,
        progress: 0.90,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dự án',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isManager
                        ? '${mockProjects.length} projects'
                        : '2 projects',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (isManager)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Xin chào, ',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                isManager ? 'Nguyen Van A 👑' : 'Tran Thi B 👤',
                style: TextStyle(
                  color: isManager
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildProjectCard(
                  context,
                  mockProjects[0],
                  Colors.purpleAccent,
                ),
                _buildProjectCard(context, mockProjects[1], Colors.blueAccent),
                if (isManager)
                  _buildProjectCard(
                    context,
                    mockProjects[2],
                    Colors.greenAccent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    ProjectModel project,
    Color progressColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectTaskScreen(projectName: project.name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161926),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              project.description,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatDot(Colors.redAccent, '${project.todoCount} todo'),
                const SizedBox(width: 12),
                _buildStatDot(
                  Colors.orangeAccent,
                  '${project.doingCount} doing',
                ),
                const SizedBox(width: 12),
                _buildStatDot(Colors.greenAccent, '${project.doneCount} done'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(project.progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
