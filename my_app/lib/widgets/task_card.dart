import 'package:flutter/material.dart';
import '../models/task_model.dart';

/// Widget TaskCard – hiển thị thông tin 1 task dạng card
/// Tái sử dụng được ở nhiều màn hình (TaskScreen, MyTaskScreen, HomePage)
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  // Màu theo trạng thái (khớp tài liệu: todo=#E74C3C, doing=#F39C12, done=#27AE60)
  static Color statusColor(String status) {
    switch (status) {
      case 'todo':
        return const Color(0xFFE74C3C);
      case 'doing':
        return const Color(0xFFF39C12);
      case 'done':
        return const Color(0xFF27AE60);
      default:
        return Colors.grey;
    }
  }

  // Icon theo trạng thái
  static IconData statusIcon(String status) {
    switch (status) {
      case 'todo':
        return Icons.radio_button_unchecked;
      case 'doing':
        return Icons.timelapse;
      case 'done':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue();
    final color = statusColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(statusIcon(task.status), color: color, size: 32),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 ${task.assignedTo}'),
            Text('📅 Deadline: ${task.deadlineFormatted}'),
            if (isOverdue)
              const Text(
                '⚠ QUÁ HẠN!',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            task.status.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: color,
        ),
        onTap: onTap,
      ),
    );
  }
}
