import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Color _statusColor(Task t) {
    if (t.isOverdue()) return Colors.redAccent;
    switch (t.status.toLowerCase()) {
      case 'todo':
        return Colors.orangeAccent;
      case 'doing':
        return Colors.amberAccent;
      case 'reviewing':
        return Colors.blueAccent;
      case 'done':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.currentUser;
    final isManager = user?.isManager ?? false;
    final isAssignedToMe = task.assignedTo == user?.id;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chi tiết nhiệm vụ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          if (isManager) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                // TODO: Navigate to Edit Task Screen (Phase B)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng sửa sẽ có trong Phase B')));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, taskProvider),
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(task).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _statusColor(task).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    task.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(task),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (task.isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'KHẨN CẤP',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Info Cards
            _buildInfoRow(Icons.calendar_today, 'Hạn chót', DateFormat('HH:mm - dd/MM/yyyy').format(task.deadline), task.isOverdue() ? Colors.redAccent : Colors.white),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Người thực hiện', task.assigneeName.isEmpty ? 'Chưa giao' : task.assigneeName, Colors.white),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.update, 'Cập nhật lần cuối', DateFormat('HH:mm - dd/MM/yyyy').format(task.updatedAt), Colors.grey),
            
            const SizedBox(height: 32),
            const Text(
              'Mô tả chi tiết',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161926),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Text(
                task.description.isEmpty ? 'Không có mô tả.' : task.description,
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Actions
            _buildActions(context, taskProvider, isManager, isAssignedToMe),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2235),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, TaskProvider provider, bool isManager, bool isAssignedToMe) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = task.status.toLowerCase();

    // Member Flow
    if (!isManager && isAssignedToMe) {
      if (status == 'todo') {
        return _buildFullWidthButton('BẮT ĐẦU LÀM', Colors.amberAccent, () => _updateStatus(context, provider, 'doing'));
      }
      if (status == 'doing') {
        return _buildFullWidthButton('GỬI DUYỆT', Colors.blueAccent, () => _updateStatus(context, provider, 'reviewing'));
      }
    }

    // Manager Flow
    if (isManager && status == 'reviewing') {
      return Row(
        children: [
          Expanded(child: _buildFullWidthButton('TỪ CHỐI', Colors.orangeAccent, () => _updateStatus(context, provider, 'doing'))),
          const SizedBox(width: 16),
          Expanded(child: _buildFullWidthButton('DUYỆT', Colors.greenAccent, () => _updateStatus(context, provider, 'done'))),
        ],
      );
    }

    // Done or no action
    if (status == 'done') {
      return _buildFullWidthButton('ĐÃ HOÀN THÀNH', Colors.greenAccent.withValues(alpha: 0.3), null);
    }

    return const SizedBox.shrink();
  }

  Widget _buildFullWidthButton(String text, Color color, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.5)),
          ),
          disabledBackgroundColor: color.withValues(alpha: 0.1),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, TaskProvider provider, String newStatus) async {
    try {
      final success = await provider.updateTaskStatus(task.id, newStatus);
      if (success && context.mounted) {
        Navigator.pop(context); // Go back after successful update
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật thành trạng thái $newStatus')));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Trạng thái không hợp lệ!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra khi cập nhật')));
      }
    }
  }

  void _confirmDelete(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        title: const Text('Xóa nhiệm vụ?', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn xóa nhiệm vụ này không? Hành động này không thể hoàn tác.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteTask(task.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa nhiệm vụ')));
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
