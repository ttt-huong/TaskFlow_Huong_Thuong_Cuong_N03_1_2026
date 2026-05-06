import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';
import '../../core/seed_data.dart';
import '../../widgets/common/main_layout.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = SeedData.initialProjects;
    final tasks = SeedData.initialTasks;

    return MainLayout(
      title: 'DỰ ÁN',
      showImage: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${projects.length} projects',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Xin chào, Trần Thị B',
              style: AppTextStyles.h2.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ...projects.map((project) {
              final projectTasks = tasks.where(
                (task) => task.projectId == project.id,
              );
              final todoCount = projectTasks
                  .where((task) => task.status == 'todo')
                  .length;
              final doingCount = projectTasks
                  .where((task) => task.status == 'doing')
                  .length;
              final doneCount = projectTasks
                  .where((task) => task.status == 'done')
                  .length;
              final totalTasks = projectTasks.length;
              final progress = totalTasks == 0 ? 0.0 : (doneCount / totalTasks);

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _ProjectCard(
                  projectName: project.name,
                  projectDescription: project.description,
                  memberCount: project.memberIds.length,
                  todoCount: todoCount,
                  doingCount: doingCount,
                  doneCount: doneCount,
                  progress: progress,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String projectName;
  final String projectDescription;
  final int memberCount;
  final int todoCount;
  final int doingCount;
  final int doneCount;
  final double progress;

  const _ProjectCard({
    required this.projectName,
    required this.projectDescription,
    required this.memberCount,
    required this.todoCount,
    required this.doingCount,
    required this.doneCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      projectDescription,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatusDot(
                          label: '$todoCount todo',
                          color: const Color(0xFFEA4335),
                        ),
                        const SizedBox(width: 8),
                        _StatusDot(
                          label: '$doingCount doing',
                          color: const Color(0xFFF9A825),
                        ),
                        const SizedBox(width: 8),
                        _StatusDot(
                          label: '$doneCount done',
                          color: const Color(0xFF34A853),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$memberCount thành viên',
                    style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.65
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFF7E57C2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }
}
