import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../repositories/impl/task_repository_impl.dart';
import '../core/app_colors.dart';
import '../widgets/common/skeleton_loader.dart';
import 'task_detail_screen.dart';

class MemberTasksScreen extends StatefulWidget {
  final UserModel user;

  const MemberTasksScreen({super.key, required this.user});

  @override
  State<MemberTasksScreen> createState() => _MemberTasksScreenState();
}

class _MemberTasksScreenState extends State<MemberTasksScreen> {
  final TaskRepositoryImpl _taskRepository = TaskRepositoryImpl();
  List<Task> _memberTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberTasks();
  }

  Future<void> _fetchMemberTasks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final tasks = await _taskRepository.getTasksByUser(widget.user.id);
      if (mounted) {
        setState(() {
          _memberTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _memberTasks = [];
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Tính toán thống kê
    final totalTasks = _memberTasks.length;
    final inProgressTasks = _memberTasks.where((t) => t.status == 'doing' || t.status == 'reviewing').length;
    final completedTasks = _memberTasks.where((t) => t.status == 'done').length;

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
          'Công việc thành viên',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMemberTasks,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.user.isManager
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.done.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.user.role.toUpperCase(),
                              style: TextStyle(
                                color: widget.user.isManager ? AppColors.error : AppColors.done,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mini Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      'Tổng số',
                      '$totalTasks',
                      Icons.assignment_outlined,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(
                      'Đang làm',
                      '$inProgressTasks',
                      Icons.trending_flat_rounded,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStatCard(
                      'Đã xong',
                      '$completedTasks',
                      Icons.check_circle_outline_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tasks List Header
              const Text(
                'Danh sách nhiệm vụ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),

              // Tasks List
              _isLoading
                  ? const SkeletonTaskList()
                  : _memberTasks.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded, size: 48, color: AppColors.secondaryText),
                              SizedBox(height: 12),
                              Text(
                                'Thành viên này chưa được giao nhiệm vụ nào',
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _memberTasks.length,
                          itemBuilder: (context, index) {
                            final task = _memberTasks[index];
                            
                            // Tìm tên dự án
                            final project = projectProvider.projects.firstWhere(
                              (p) => p.id == task.projectId,
                              orElse: () => ProjectModel(id: '', name: 'Dự án khác', description: '', memberIds: []),
                            );

                            return Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
                              ),
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                                  );
                                  _fetchMemberTasks(); // reload lists when returning
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _statusColor(task),
                                          borderRadius: BorderRadius.circular(4),
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
                                                color: AppColors.text,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.folder_open_rounded, size: 12, color: AppColors.secondaryText),
                                                const SizedBox(width: 4),
                                                Text(
                                                  project.name,
                                                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
                                                ),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.secondaryText),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('dd/MM').format(task.deadline),
                                                  style: TextStyle(
                                                    color: task.isOverdue() ? AppColors.error : AppColors.secondaryText,
                                                    fontSize: 11,
                                                    fontWeight: task.isOverdue() ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(task).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          task.status.toUpperCase(),
                                          style: TextStyle(
                                            color: _statusColor(task),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color.withValues(alpha: 0.6), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
