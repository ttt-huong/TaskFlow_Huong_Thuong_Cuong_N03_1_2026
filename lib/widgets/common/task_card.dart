import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/app_colors.dart';

/// Widget TaskCard – hiển thị thông tin 1 task dạng card premium, không viền cứng, đổ bóng mịn
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  // Màu theo trạng thái (Sử dụng AppColors tập trung)
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return AppColors.todo;
      case 'doing':
        return AppColors.doing;
      case 'reviewing':
        return AppColors.reviewing;
      case 'done':
        return AppColors.done;
      default:
        return AppColors.grey;
    }
  }

  static String _getStatusLabelVi(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return 'Chưa làm';
      case 'doing':
        return 'Đang làm';
      case 'reviewing':
        return 'Chờ duyệt';
      case 'done':
        return 'Đã xong';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue();
    final color = statusColor(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isOverdue
                ? AppColors.error.withValues(alpha: 0.08)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Cột trạng thái: Chấm tròn và thanh màu chỉ thị
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color, width: 2.5),
                  ),
                ),
                const SizedBox(width: 16),

                // Nội dung chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.isUrgent) ...[
                            const SizedBox(width: 6),
                            _buildMiniTag('GẤP', AppColors.error),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildMiniTag(_getStatusLabelVi(task.status), color),
                          if (isOverdue) _buildMiniTag('Quá hạn ⚠', AppColors.error),
                          if (task.assigneeName.isNotEmpty) _buildAssigneeChip(task),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Deadline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.deadlineFormatted,
                      style: TextStyle(
                        color: isOverdue ? AppColors.error : AppColors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Hạn chót',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAssigneeChip(Task task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            task.assigneeAvatar.isNotEmpty
                ? task.assigneeAvatar
                : (task.assigneeName.isNotEmpty ? task.assigneeName[0].toUpperCase() : '?'),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            task.assigneeName,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
