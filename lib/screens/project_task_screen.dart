import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../core/app_colors.dart';
import '../widgets/common/skeleton_loader.dart';
import 'task_detail_screen.dart';

class ProjectTaskScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  const ProjectTaskScreen({super.key, required this.projectId, required this.projectName});

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
  String _selectedFilter = 'Tất cả';
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedCalendarDay;
  bool _isKanbanView = false; // Mặc định là chế độ List

  @override
  void initState() {
    super.initState();
    _selectedCalendarDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasksByProject(widget.projectId);
      Provider.of<ProjectProvider>(context, listen: false).loadAllUsers();
    });
  }

  Color _statusColor(Task task) {
    if (task.isOverdue()) {
      return AppColors.error;
    }
    switch (task.status.toLowerCase()) {
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

  // --- Logic cho Custom Calendar ---
  List<DateTime> _daysInMonthList(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    
    int weekdayOffset = first.weekday - 1; // 0 = Thứ Hai, 6 = Chủ Nhật
    
    List<DateTime> days = [];
    
    for (int i = weekdayOffset; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }
    
    for (int i = 0; i < last.day; i++) {
      days.add(first.add(Duration(days: i)));
    }
    
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isManager = authProvider.currentUser?.isManager ?? false;
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Lấy dự án hiện tại
    final currentProject = projectProvider.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => ProjectModel(id: widget.projectId, name: widget.projectName, description: '', memberIds: []),
    );

    // Lọc theo vai trò: Quyền Member chỉ thấy task của chính họ gán
    List<Task> roleFiltered = isManager
        ? taskProvider.tasks
        : taskProvider.tasks.where((task) => task.assignedTo == authProvider.currentUser?.id).toList();

    // Lọc tiếp theo bộ lọc trạng thái
    List<Task> finalFilteredTasks = roleFiltered;
    if (_selectedFilter != 'Tất cả') {
      finalFilteredTasks = roleFiltered
          .where((task) => task.status.toLowerCase() == _selectedFilter.toLowerCase() ||
              (task.status.toLowerCase() == 'reviewing' && _selectedFilter == 'Review'))
          .toList();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.text,
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
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                isManager
                    ? '${taskProvider.tasks.length} nhiệm vụ'
                    : '${roleFiltered.length} nhiệm vụ của bạn',
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
            ],
          ),
          actions: [
            if (isManager) ...[
              IconButton(
                icon: const Icon(Icons.people_alt_outlined, color: AppColors.primary),
                onPressed: () => _showManageMembersDialog(context, projectProvider, currentProject),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddTaskDialog(context, projectProvider, currentProject),
                  ),
                ),
              ),
            ]
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.text,
            unselectedLabelColor: AppColors.secondaryText,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Danh sách'),
              Tab(text: 'Lịch biểu'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: DANH SÁCH NHIỆM VỤ ---
            RefreshIndicator(
              onRefresh: () async {
                final taskProv = Provider.of<TaskProvider>(context, listen: false);
                final projProv = Provider.of<ProjectProvider>(context, listen: false);
                await taskProv.loadTasksByProject(widget.projectId);
                await projProv.loadAllUsers();
              },
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh Filter ngang
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Tất cả', 'Todo', 'Doing', 'Reviewing', 'Done'].map((tab) {
                              final isSelected = _selectedFilter == tab;
                              final displayTab = tab == 'Reviewing' ? 'Chờ duyệt' : tab;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilter = tab),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    displayTab,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.secondaryText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Thanh chế độ xem List / Kanban & Vai trò
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isManager
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Quản lý dự án',
                                          style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.shield_rounded, color: AppColors.primary, size: 14),
                                      ],
                                    ),
                                  )
                                : const Expanded(
                                    child: Text(
                                      'Chỉ hiển thị công việc giao cho bạn',
                                      style: TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                            
                            // Nút Toggle List / Kanban
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.list_rounded),
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    color: !_isKanbanView ? AppColors.primary : AppColors.secondaryText,
                                    onPressed: () => setState(() => _isKanbanView = false),
                                  ),
                                  const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                                  IconButton(
                                    icon: const Icon(Icons.grid_view_rounded),
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    color: _isKanbanView ? AppColors.primary : AppColors.secondaryText,
                                    onPressed: () => setState(() => _isKanbanView = true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: taskProvider.isLoading
                              ? const SkeletonTaskList()
                              : _isKanbanView
                                  ? _buildKanbanBoard(roleFiltered, isManager, taskProvider)
                                  : finalFilteredTasks.isEmpty
                                      ? ListView(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          children: [
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.4,
                                              child: const Center(
                                                child: Text(
                                                  'Không có công việc nào',
                                                  style: TextStyle(color: AppColors.secondaryText),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                      itemCount: finalFilteredTasks.length,
                                      itemBuilder: (context, index) {
                                        final task = finalFilteredTasks[index];
                                        final bool isReviewing = task.status.toLowerCase() == 'reviewing';

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
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                                              ).then((_) {
                                                // Refresh task list
                                                if (!mounted) return;
                                                Provider.of<TaskProvider>(this.context, listen: false).loadTasksByProject(widget.projectId);
                                              });
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
                                                        const SizedBox(height: 6),
                                                        Wrap(
                                                          spacing: 8,
                                                          runSpacing: 4,
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                                            if (isManager && isReviewing) ...[
                                                              GestureDetector(
                                                                onTap: () => taskProvider.updateTaskStatus(task.id, 'doing'),
                                                                child: _buildActionButton('Từ chối', AppColors.doing),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () => taskProvider.updateTaskStatus(task.id, 'done'),
                                                                child: _buildActionButton('Duyệt', AppColors.done),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: 14,
                                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                                    child: Text(
                                                      task.assigneeAvatar.isNotEmpty
                                                          ? task.assigneeAvatar
                                                          : (task.assigneeName.isNotEmpty
                                                              ? task.assigneeName.substring(0, 1).toUpperCase()
                                                              : '?'),
                                                      style: const TextStyle(
                                                        color: AppColors.primary,
                                                        fontSize: 11,
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
                        ),
                      ],
                    ),
                  ),
                ),

                  // --- TAB 2: LỊCH BIỂU (CALENDAR VIEW) ---
                  RefreshIndicator(
                    onRefresh: () async {
                      final taskProv = Provider.of<TaskProvider>(context, listen: false);
                      final projProv = Provider.of<ProjectProvider>(context, listen: false);
                      await taskProv.loadTasksByProject(widget.projectId);
                      await projProv.loadAllUsers();
                    },
                    color: AppColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: AppColors.text),
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                'Tháng ${_currentMonth.month} / ${_currentMonth.year}',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppColors.text),
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
                            return SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),

                        Expanded(
                          flex: 3,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: _daysInMonthList(_currentMonth).length,
                            itemBuilder: (context, index) {
                              final allDays = _daysInMonthList(_currentMonth);
                              final day = allDays[index];
                              final isCurrentMonth = day.month == _currentMonth.month;
                              final isToday = _isSameDay(day, DateTime.now());
                              final isSelected = _selectedCalendarDay != null && _isSameDay(day, _selectedCalendarDay!);

                              final dayTasks = roleFiltered.where((t) => _isSameDay(t.deadline, day)).toList();

                              return GestureDetector(
                                key: ValueKey('day_${day.day}_${day.month}'),
                                onTap: () {
                                  setState(() {
                                    _selectedCalendarDay = day;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isToday && !isSelected
                                          ? AppColors.primary.withValues(alpha: 0.5)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color: isCurrentMonth
                                              ? (isSelected ? Colors.white : (isToday ? AppColors.primary : AppColors.text))
                                              : Colors.grey.withValues(alpha: 0.4),
                                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      if (dayTasks.isNotEmpty)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            ...dayTasks.take(2).map((t) {
                                              return Container(
                                                width: 5,
                                                height: 5,
                                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? Colors.white : _statusColor(t),
                                                  shape: BoxShape.circle,
                                                ),
                                              );
                                            }),
                                            if (dayTasks.length > 2)
                                              Text(
                                                '+${dayTasks.length - 2}',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: isSelected ? Colors.white : AppColors.secondaryText,
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

                        const Divider(color: Color(0xFFE2E8F0), height: 1),
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCalendarDay == null
                                    ? 'Chọn một ngày trên lịch'
                                    : 'Nhiệm vụ ngày ${_selectedCalendarDay!.day}/${_selectedCalendarDay!.month}',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedCalendarDay != null)
                              Text(
                                '${roleFiltered.where((t) => _isSameDay(t.deadline, _selectedCalendarDay!)).length} việc',
                                style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Expanded(
                          flex: 2,
                          child: taskProvider.isLoading
                              ? const SkeletonTaskList()
                              : _selectedCalendarDay == null
                                  ? const Center(
                                      child: Text(
                                        'Hãy nhấn vào một ngày để xem danh sách',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                      ),
                                    )
                                  : () {
                                  final dayTasks = roleFiltered.where((t) => _isSameDay(t.deadline, _selectedCalendarDay!)).toList();
                                  if (dayTasks.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Không có nhiệm vụ nào trong ngày này',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13, fontStyle: FontStyle.italic),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: dayTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = dayTasks[index];
                                      return Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                                            ).then((_) {
                                              if (!mounted) return;
                                              Provider.of<TaskProvider>(this.context, listen: false).loadTasksByProject(widget.projectId);
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 3,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(task),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    task.title,
                                                    style: const TextStyle(
                                                      color: AppColors.text,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(task).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
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
                                  );
                                }(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(List<Task> tasks, bool isManager, TaskProvider taskProvider) {
    final statuses = ['todo', 'doing', 'reviewing', 'done'];
    final statusLabels = {
      'todo': 'CẦN LÀM',
      'doing': 'ĐANG LÀM',
      'reviewing': 'CHỜ DUYỆT',
      'done': 'HOÀN THÀNH',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statuses.map((statusKey) {
          final columnTasks = tasks.where((t) => t.status.toLowerCase() == statusKey).toList();
          final Color statusCol = _statusColorForTimeline(statusKey);

          return Container(
            width: MediaQuery.of(context).size.width * 0.78,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusCol,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusLabels[statusKey]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.text,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusCol.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${columnTasks.length}',
                          style: TextStyle(
                            color: statusCol,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.52,
                  ),
                  child: columnTasks.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              'Không có công việc',
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: columnTasks.length,
                          itemBuilder: (context, index) {
                            final task = columnTasks[index];
                            final bool isReviewing = task.status.toLowerCase() == 'reviewing';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FD),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                                  ).then((_) {
                                    if (!mounted) return;
                                    Provider.of<TaskProvider>(this.context, listen: false).loadTasksByProject(widget.projectId);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.text,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text(
                                                task.deadlineShort,
                                                style: TextStyle(
                                                  color: task.isOverdue() ? AppColors.error : AppColors.secondaryText,
                                                  fontSize: 11,
                                                  fontWeight: task.isOverdue() ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                          CircleAvatar(
                                            radius: 11,
                                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                            child: Text(
                                              task.assigneeAvatar.isNotEmpty
                                                  ? task.assigneeAvatar
                                                  : (task.assigneeName.isNotEmpty
                                                      ? task.assigneeName.substring(0, 1).toUpperCase()
                                                      : '?'),
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isManager && isReviewing) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () => taskProvider.updateTaskStatus(task.id, 'doing'),
                                              child: _buildActionButton('Từ chối', AppColors.doing),
                                            ),
                                            GestureDetector(
                                              onTap: () => taskProvider.updateTaskStatus(task.id, 'done'),
                                              child: _buildActionButton('Duyệt', AppColors.done),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showManageMembersDialog(BuildContext context, ProjectProvider projectProvider, ProjectModel project) {
    final List<String> currentMemberIds = List.from(project.memberIds);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Quản lý thành viên', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 320,
                child: projectProvider.allUsers.isEmpty
                    ? const Center(child: Text('Không tìm thấy thành viên nào.'))
                    : ListView.builder(
                        itemCount: projectProvider.allUsers.length,
                        itemBuilder: (context, index) {
                          final user = projectProvider.allUsers[index];
                          final isChecked = currentMemberIds.contains(user.id);

                          return CheckboxListTile(
                            activeColor: AppColors.primary,
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                            value: isChecked,
                            onChanged: (bool? val) {
                              setState(() {
                                if (val == true) {
                                  currentMemberIds.add(user.id);
                                } else {
                                  currentMemberIds.remove(user.id);
                                }
                              });
                            },
                          );
                        },
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
                    project.memberIds = currentMemberIds;
                    await projectProvider.updateProject(project);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Đã cập nhật danh sách thành viên dự án'),
                        backgroundColor: AppColors.done,
                      ));
                    }
                  },
                  child: const Text('Lưu lại', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, ProjectProvider projectProvider, ProjectModel project) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    
    // Lọc danh sách thành viên thực tế của dự án
    final List<UserModel> projectMembers = projectProvider.allUsers
        .where((u) => project.memberIds.contains(u.id))
        .toList();

    String? selectedUser = projectMembers.isNotEmpty ? projectMembers.first.id : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Thêm nhiệm vụ mới', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              content: Column(
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
                              'Dự án chưa có thành viên. Hãy gán thành viên cho dự án trước.',
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
                      initialValue: selectedUser,
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
                  onPressed: projectMembers.isEmpty
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final desc = descController.text.trim();
                          if (title.isNotEmpty && selectedUser != null) {
                            final user = projectMembers.firstWhere(
                              (u) => u.id == selectedUser,
                            );
                            final assigneeName = user.name;
                            final assigneeAvatar = user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?';

                            await Provider.of<TaskProvider>(context, listen: false).createTask(
                              title,
                              desc,
                              widget.projectId,
                              selectedUser!,
                              DateTime.now().add(const Duration(days: 7)),
                              assigneeName: assigneeName,
                              assigneeAvatar: assigneeAvatar,
                            );
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                  child: const Text('Tạo', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
