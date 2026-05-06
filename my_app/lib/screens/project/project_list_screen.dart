import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/common/main_layout.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dự án',
      showImage: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2 projects', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),
            RichText(
              text: const TextSpan(
                text: 'Xin chào, ',
                style: TextStyle(color: Colors.black87, fontSize: 16),
                children: [
                  TextSpan(
                    text: 'Tran Thi B 👤',
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ProjectCard(
                    title: 'App Flutter',
                    subtitle: 'Quản lý công việc nhóm',
                    todo: 2, doing: 3, done: 4,
                    progress: 0.65,
                    progressColor: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  ProjectCard(
                    title: 'Báo cáo môn học',
                    subtitle: 'Tài liệu + slide',
                    todo: 4, doing: 1, done: 1,
                    progress: 0.3,
                    progressColor: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int todo, doing, done;
  final double progress;
  final Color progressColor;

  const ProjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.todo,
    required this.doing,
    required this.done,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền sáng
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatusDot(Colors.red, '$todo todo'),
              const SizedBox(width: 12),
              _buildStatusDot(Colors.orange, '$doing doing'),
              const SizedBox(width: 12),
              _buildStatusDot(Colors.green, '$done done'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.group, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('3 thành viên', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: progressColor,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(progress * 100).toInt()}%', 
                style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}