import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../core/app_colors.dart';
import '../providers/notification_provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';


class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Color _statusColor(Task t) {
    if (t.isOverdue()) return AppColors.error;
    switch (t.status.toLowerCase()) {
      case 'todo':
        return AppColors.todo;
      case 'doing':
        return AppColors.doing;
      case 'reviewing':
        return AppColors.reviewing;
      case 'done':
        return AppColors.done;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  Color _statusColorForTimeline(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return AppColors.todo;
      case 'doing':
        return AppColors.doing;
      case 'reviewing':
        return AppColors.reviewing;
      case 'done':
        return AppColors.done;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  List<_TimelineStep> _buildTimelineSteps(Task task) {
    final status = task.status.toLowerCase();
    final steps = <_TimelineStep>[];

    // Bước 1: Tạo nhiệm vụ
    steps.add(_TimelineStep(
      title: 'Đã tạo nhiệm vụ',
      statusKey: 'todo',
      subtitle: 'Nhiệm vụ được tạo với trạng thái ban đầu là TODO',
      isCompleted: true,
      isActive: status == 'todo',
      time: task.updatedAt,
    ));

    // Bước 2: Bắt đầu làm
    final isDoingDone = status == 'doing' || status == 'reviewing' || status == 'done';
    steps.add(_TimelineStep(
      title: 'Thành viên bắt đầu làm',
      statusKey: 'doing',
      subtitle: 'Thành viên nhận việc và bắt đầu thực hiện',
      isCompleted: isDoingDone,
      isActive: status == 'doing',
      time: status == 'doing' ? task.updatedAt : null,
    ));

    // Bước 3: Gửi duyệt
    final isReviewingDone = status == 'reviewing' || status == 'done';
    steps.add(_TimelineStep(
      title: 'Chờ quản lý duyệt',
      statusKey: 'reviewing',
      subtitle: 'Nhiệm vụ đã làm xong và đang chờ phê duyệt',
      isCompleted: isReviewingDone,
      isActive: status == 'reviewing',
      time: status == 'reviewing' ? task.updatedAt : null,
    ));

    // Bước 4: Hoàn thành hoặc Hủy
    if (status == 'cancelled') {
      steps.add(_TimelineStep(
        title: 'Nhiệm vụ đã hủy',
        statusKey: 'cancelled',
        subtitle: 'Quản lý đã hủy bỏ nhiệm vụ này',
        isCompleted: true,
        isActive: true,
        time: task.updatedAt,
      ));
    } else {
      steps.add(_TimelineStep(
        title: 'Đã hoàn thành',
        statusKey: 'done',
        subtitle: 'Nhiệm vụ đã được phê duyệt và hoàn thành',
        isCompleted: status == 'done',
        isActive: status == 'done',
        time: status == 'done' ? task.updatedAt : null,
      ));
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    // Lấy task mới nhất từ Provider để cập nhật UI ngay lập tức
    final currentTask = taskProvider.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    final user = authProvider.currentUser;
    final isManager = user?.isManager ?? false;
    final isAssignedToMe = currentTask.assignedTo == user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết nhiệm vụ',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isManager) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showEditTaskDialog(context, currentTask),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _confirmDelete(context, taskProvider, currentTask.id),
            ),
          ]
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(currentTask).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor(currentTask).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    currentTask.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(currentTask),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (currentTask.isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'KHẨN CẤP 🚨',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentTask.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    'Hạn chót',
                    DateFormat('HH:mm - dd/MM/yyyy').format(currentTask.deadline.toLocal()),
                    currentTask.isOverdue() ? AppColors.error : AppColors.text,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _buildInfoRow(
                    Icons.person_outline_rounded,
                    'Người thực hiện',
                    currentTask.assigneeName.isEmpty ? 'Chưa giao' : currentTask.assigneeName,
                    AppColors.text,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
                  _buildInfoRow(
                    Icons.update_rounded,
                    'Cập nhật lần cuối',
                    DateFormat('HH:mm - dd/MM/yyyy').format(currentTask.updatedAt.toLocal()),
                    AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            if (currentTask.rejectionReason.trim().isNotEmpty &&
                currentTask.status.toLowerCase() == 'todo') ...[
              _buildRejectBanner(currentTask.rejectionReason.trim()),
              const SizedBox(height: 24),
            ],

            const Text(
              'Mô tả chi tiết',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                currentTask.description.isEmpty ? 'Không có mô tả chi tiết.' : currentTask.description,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dynamic Status Timeline
            _buildTimeline(currentTask),
            
            const SizedBox(height: 32),
            
            // Action buttons
            _buildActions(context, taskProvider, currentTask, isManager, isAssignedToMe),
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
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.secondaryText, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectBanner(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assignment_late_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lý do từ chối',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Task task) {
    final steps = _buildTimelineSteps(task);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử trạng thái',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              final Color themeColor = _statusColorForTimeline(step.statusKey);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isCompleted
                              ? themeColor.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: step.isCompleted ? themeColor : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          step.isCompleted ? Icons.check : Icons.circle,
                          size: step.isCompleted ? 12 : 6,
                          color: step.isCompleted ? themeColor : Colors.grey.shade400,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: step.isCompleted && steps[index + 1].isCompleted
                              ? themeColor
                              : Colors.grey.shade200,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: step.isActive ? FontWeight.bold : FontWeight.w600,
                                  color: step.isActive
                                      ? AppColors.text
                                      : (step.isCompleted ? AppColors.text : AppColors.secondaryText),
                                ),
                              ),
                            ),
                            if (step.time != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm - dd/MM').format(step.time!.toLocal()),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: step.isCompleted ? AppColors.secondaryText : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, TaskProvider provider, Task currentTask, bool isManager, bool isAssignedToMe) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = currentTask.status.toLowerCase();

    // Member Flow
    if (!isManager && isAssignedToMe) {
      if (status == 'todo') {
        return _buildFullWidthButton('BẮT ĐẦU LÀM', AppColors.doing, () => _updateStatus(context, provider, currentTask, 'doing'));
      }
      if (status == 'doing') {
        return _buildFullWidthButton('GỬI DUYỆT 📤', AppColors.reviewing, () => _updateStatus(context, provider, currentTask, 'reviewing'));
      }
    }

    // Manager Flow
    if (isManager && status == 'reviewing') {
      return Row(
        children: [
          Expanded(child: _buildFullWidthButton('Từ chối', AppColors.error, () => _showRejectDialog(context, provider, currentTask.id))),
          const SizedBox(width: 16),
          Expanded(child: _buildFullWidthButton('DUYỆT', AppColors.done, () => _approveTask(context, provider, currentTask.id))),
        ],
      );
    }

    // Done or no action
    if (status == 'done') {
      return _buildFullWidthButton('NHIỆM VỤ ĐÃ HOÀN THÀNH 🎉', AppColors.done.withValues(alpha: 0.5), null);
    }

    if (status == 'cancelled') {
      return _buildFullWidthButton('ĐÃ HỦY 🚫', AppColors.error.withValues(alpha: 0.5), null);
    }

    return const SizedBox.shrink();
  }

  Widget _buildFullWidthButton(String text, Color color, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          disabledBackgroundColor: color.withValues(alpha: 0.05),
          disabledForegroundColor: color.withValues(alpha: 0.5),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, TaskProvider provider, Task currentTask, String newStatus) async {
    try {
      final success = await provider.updateTaskStatus(currentTask.id, newStatus);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
          content: Text('Đã cập nhật trạng thái thành: ${newStatus.toUpperCase()}'),
          backgroundColor: _statusColorForTimeline(newStatus),
        ));
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(
          content: Text('Lỗi: Trạng thái chuyển đổi không hợp lệ!'),
          backgroundColor: AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _approveTask(BuildContext context, TaskProvider provider, String taskId) async {
    final success = await provider.approveTask(taskId);
    if (!mounted) return;

    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
      content: Text(success
          ? 'Đã duyệt nhiệm vụ thành công.'
          : 'Không thể duyệt nhiệm vụ này.'),
      backgroundColor: success ? AppColors.done : AppColors.error,
    ));
  }

  void _showRejectDialog(BuildContext context, TaskProvider provider, String taskId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Từ chối nhiệm vụ',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Nhập lý do từ chối...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Vui lòng nhập lý do từ chối.'),
                  backgroundColor: AppColors.error,
                ));
                return;
              }

              Navigator.pop(ctx);
              final success = await provider.rejectTask(taskId, reason);
              if (!mounted) return;

              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                content: Text(success
                    ? 'Đã từ chối nhiệm vụ và gửi lý do cho thành viên.'
                    : 'Không thể từ chối nhiệm vụ này.'),
                backgroundColor: success ? AppColors.error : AppColors.error,
              ));
            },
            child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa nhiệm vụ?', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa nhiệm vụ này không? Hành động này không thể hoàn tác.', style: TextStyle(color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Hủy', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteTask(taskId);
              if (context.mounted) {
                Provider.of<NotificationProvider>(context, listen: false).deleteNotificationsByTaskId(taskId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Đã xóa nhiệm vụ thành công'),
                  backgroundColor: AppColors.error,
                ));
              }
            },
            child: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final currentProject = projectProvider.projects.firstWhere(
      (p) => p.id == task.projectId,
      orElse: () => ProjectModel(id: task.projectId, name: '', description: '', memberIds: []),
    );
    final List<UserModel> projectMembers = projectProvider.allUsers
        .where((u) => currentProject.memberIds.contains(u.id))
        .toList();

    String? selectedUser = projectMembers.any((m) => m.id == task.assignedTo)
        ? task.assignedTo
        : (projectMembers.isNotEmpty ? projectMembers.first.id : null);

    DateTime selectedDeadline = task.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Chỉnh sửa nhiệm vụ', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề',
                        labelStyle: TextStyle(color: AppColors.secondaryText),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        labelStyle: TextStyle(color: AppColors.secondaryText),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hạn chót:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text)),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                          label: Text(
                            DateFormat('HH:mm dd/MM/yyyy').format(selectedDeadline.toLocal()),
                            style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDeadline.toLocal(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (date != null) {
                              if (!context.mounted) return;
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDeadline.toLocal()),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedDeadline = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (projectMembers.isEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.doing.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.doing, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dự án chưa có thành viên để gán nhiệm vụ.',
                                style: TextStyle(color: AppColors.doing, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text('Giao cho thành viên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedUser,
                        hint: const Text('Chọn thành viên gán task'),
                        items: projectMembers.map((u) {
                          return DropdownMenuItem<String>(
                            value: u.id,
                            child: Text(u.name, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedUser = val;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isNotEmpty) {
                      String assigneeName = '';
                      String assigneeAvatar = '?';
                      if (selectedUser != null) {
                        final user = projectMembers.firstWhere(
                          (u) => u.id == selectedUser,
                          orElse: () => UserModel(id: selectedUser!, name: task.assigneeName, email: '', password: '', role: 'member'),
                        );
                        assigneeName = user.name;
                        assigneeAvatar = user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?';
                      }

                      final updatedTask = task.copyWith(
                        title: title,
                        description: desc,
                        deadline: selectedDeadline.toUtc(),
                        assignedTo: selectedUser ?? '',
                        assigneeName: assigneeName,
                        assigneeAvatar: assigneeAvatar,
                      );

                      await Provider.of<TaskProvider>(context, listen: false).editTask(updatedTask);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Đã cập nhật nhiệm vụ thành công 🎉'),
                          backgroundColor: AppColors.done,
                        ));
                      }
                    }
                  },
                  child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


class _TimelineStep {
  final String title;
  final String statusKey;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final DateTime? time;

  _TimelineStep({
    required this.title,
    required this.statusKey,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    this.time,
  });
}
