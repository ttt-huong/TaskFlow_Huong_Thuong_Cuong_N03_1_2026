import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import 'task_detail_screen.dart';

class ProjectTaskScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  const ProjectTaskScreen(
      {super.key, required this.projectId, required this.projectName});

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tất cả';
  String _selectedMemberId = '';
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedCalendarDay;

  // Status colors
  static const Map<String, Color> statusColors = {
    'todo': Color(0xFFEF4444),
    'doing': Color(0xFFF59E0B),
    'reviewing': Color(0xFF3B82F6),
    'done': Color(0xFF10B981),
  };

  // Priority colors
  static const Map<String, Color> priorityColors = {
    'low': Color(0xFF10B981),
    'medium': Color(0xFF3B82F6),
    'high': Color(0xFFF59E0B),
    'critical': Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedCalendarDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false)
          .loadTasksByProject(widget.projectId);
      Provider.of<ProjectProvider>(context, listen: false).loadAllUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(Task task) {
    if (task.isOverdue()) return const Color(0xFFEF4444);
    return statusColors[task.status.toLowerCase()] ?? Colors.grey;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _daysInMonthList(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    int weekdayOffset = first.weekday - 1;
    List<DateTime> days = [];
    for (int i = weekdayOffset; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }
    for (int i = 0; i < last.day; i++) {
      days.add(first.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isManager = authProvider.currentUser?.isManager ?? false;
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Role filter
    List<Task> roleFiltered = isManager
        ? taskProvider.tasks
        : taskProvider.tasks
            .where((t) => t.assignedTo == authProvider.currentUser?.id)
            .toList();

    // Member filter
    List<Task> memberFiltered = _selectedMemberId.isEmpty
        ? roleFiltered
        : roleFiltered.where((t) => t.assignedTo == _selectedMemberId).toList();

    // Status filter
    List<Task> finalTasks = _selectedFilter == 'Tất cả'
        ? memberFiltered
        : memberFiltered.where((t) {
            if (_selectedFilter == 'Review')
              return t.status.toLowerCase() == 'reviewing';
            return t.status.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.projectName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text(
              isManager
                  ? '${taskProvider.tasks.length} nhiệm vụ'
                  : '${roleFiltered.length} nhiệm vụ của bạn',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: () =>
                    _showAddTaskDialog(context, taskProvider, projectProvider),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8B5CF6),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Danh sách'),
            Tab(text: 'Lịch biểu'),
            Tab(text: 'Thành viên'),
            Tab(text: 'Thống kê'),
          ],
        ),
      ),
      body: taskProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskListTab(context, isManager, taskProvider,
                    projectProvider, finalTasks, roleFiltered),
                _buildCalendarTab(roleFiltered),
                _buildMembersTab(
                    context, isManager, taskProvider, projectProvider),
                _buildStatsTab(taskProvider, roleFiltered),
              ],
            ),
    );
  }

  // ════════════════════════════════════════
  // TAB 1: DANH SÁCH NHIỆM VỤ
  // ════════════════════════════════════════
  Widget _buildTaskListTab(
      BuildContext context,
      bool isManager,
      TaskProvider taskProvider,
      ProjectProvider projectProvider,
      List<Task> finalTasks,
      List<Task> roleFiltered) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats bar
          _TaskStatsBar(tasks: roleFiltered),
          const SizedBox(height: 14),

          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((tab) {
                final isSelected = _selectedFilter == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF1E2235),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color:
                                      const Color(0xFF8B5CF6).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ]
                          : [],
                    ),
                    child: Text(tab,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Member filter (Manager only)
          if (isManager)
            _MemberDropdown(
              allUsers: projectProvider.allUsers,
              selectedId: _selectedMemberId,
              onChanged: (id) => setState(() => _selectedMemberId = id),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 14),
                  SizedBox(width: 6),
                  Text('Chỉ hiển thị task được gán cho bạn',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Task list
          Expanded(
            child: finalTasks.isEmpty
                ? const Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded, color: Colors.grey, size: 48),
                      SizedBox(height: 12),
                      Text('Không có task nào',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ))
                : ListView.builder(
                    itemCount: finalTasks.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final task = finalTasks[index];
                      return _TaskCard(
                        task: task,
                        isManager: isManager,
                        statusColor: _statusColor(task),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: task))),
                        onApprove: () =>
                            taskProvider.updateTaskStatus(task.id, 'done'),
                        onReject: () =>
                            taskProvider.updateTaskStatus(task.id, 'doing'),
                        onDelete: isManager
                            ? () => taskProvider.deleteTask(task.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // TAB 2: LỊCH BIỂU
  // ════════════════════════════════════════
  Widget _buildCalendarTab(List<Task> roleFiltered) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => setState(() => _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month - 1, 1)),
              ),
              Text(
                'Tháng ${_currentMonth.month} / ${_currentMonth.year}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => setState(() => _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month + 1, 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((d) {
              return SizedBox(
                width: 40,
                child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
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
                final isSelected = _selectedCalendarDay != null &&
                    _isSameDay(day, _selectedCalendarDay!);
                final dayTasks = roleFiltered
                    .where((t) => _isSameDay(t.deadline, day))
                    .toList();

                return GestureDetector(
                  onTap: () => setState(() => _selectedCalendarDay = day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : (isToday
                              ? const Color(0xFF1E2235)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday && !isSelected
                            ? const Color(0xFF8B5CF6).withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isCurrentMonth
                                ? (isSelected
                                    ? Colors.white
                                    : (isToday
                                        ? const Color(0xFF8B5CF6)
                                        : Colors.white))
                                : Colors.grey.withOpacity(0.4),
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (dayTasks.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...dayTasks.take(2).map((t) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : _statusColor(t),
                                      shape: BoxShape.circle,
                                    ),
                                  )),
                              if (dayTasks.length > 2)
                                Text('+${dayTasks.length - 2}',
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: Color(0xFF1E2235)),
          const SizedBox(height: 8),

          // Selected day tasks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCalendarDay == null
                    ? 'Chọn một ngày'
                    : 'Nhiệm vụ ngày ${_selectedCalendarDay!.day}/${_selectedCalendarDay!.month}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              if (_selectedCalendarDay != null)
                Text(
                  '${roleFiltered.where((t) => _isSameDay(t.deadline, _selectedCalendarDay!)).length} việc',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            flex: 2,
            child: _selectedCalendarDay == null
                ? const Center(
                    child: Text('Nhấn vào ngày để xem task',
                        style: TextStyle(color: Colors.grey)))
                : Builder(builder: (_) {
                    final dayTasks = roleFiltered
                        .where((t) =>
                            _isSameDay(t.deadline, _selectedCalendarDay!))
                        .toList();
                    if (dayTasks.isEmpty) {
                      return const Center(
                          child: Text('Không có nhiệm vụ nào',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)));
                    }
                    return ListView.builder(
                      itemCount: dayTasks.length,
                      itemBuilder: (context, index) {
                        final task = dayTasks[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen(task: task))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF161926),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color: _statusColor(task),
                                      borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(task.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(task).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(task.status.toUpperCase(),
                                      style: TextStyle(
                                          color: _statusColor(task),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // TAB 3: THÀNH VIÊN
  // ════════════════════════════════════════
  Widget _buildMembersTab(BuildContext context, bool isManager,
      TaskProvider taskProvider, ProjectProvider projectProvider) {
    final members = projectProvider.allUsers;
    if (members.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final user = members[index];
        final userTasks =
            taskProvider.tasks.where((t) => t.assignedTo == user.id).toList();
        final doneTasks = userTasks.where((t) => t.status == 'done').length;
        final completion =
            userTasks.isEmpty ? 0.0 : doneTasks / userTasks.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161926),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isManager
                                ? const Color(0xFF8B5CF6).withOpacity(0.15)
                                : Colors.blueAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.isManager ? 'Manager' : 'Member',
                            style: TextStyle(
                              color: user.isManager
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completion,
                              backgroundColor: const Color(0xFF1E2235),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF10B981)),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$doneTasks/${userTasks.length}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════
  // TAB 4: THỐNG KÊ
  // ════════════════════════════════════════
  Widget _buildStatsTab(TaskProvider taskProvider, List<Task> roleFiltered) {
    final total = roleFiltered.length;
    final todo = roleFiltered.where((t) => t.status == 'todo').length;
    final doing = roleFiltered.where((t) => t.status == 'doing').length;
    final reviewing = roleFiltered.where((t) => t.status == 'reviewing').length;
    final done = roleFiltered.where((t) => t.status == 'done').length;
    final overdue = roleFiltered.where((t) => t.isOverdue()).length;
    final score = taskProvider.productivityScore();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Productivity score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161926),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Productivity Score',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            taskProvider.productivityColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        taskProvider.productivityLabel(),
                        style: TextStyle(
                            color: taskProvider.productivityColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFF1E2235),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            taskProvider.productivityColor()),
                      ),
                    ),
                    Text('$score%',
                        style: TextStyle(
                            color: taskProvider.productivityColor(),
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Task breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161926),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phân bổ trạng thái',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 16),
                if (total > 0) ...[
                  _StatBar(
                      label: 'Todo',
                      count: todo,
                      total: total,
                      color: const Color(0xFFEF4444)),
                  _StatBar(
                      label: 'Doing',
                      count: doing,
                      total: total,
                      color: const Color(0xFFF59E0B)),
                  _StatBar(
                      label: 'Review',
                      count: reviewing,
                      total: total,
                      color: const Color(0xFF3B82F6)),
                  _StatBar(
                      label: 'Done',
                      count: done,
                      total: total,
                      color: const Color(0xFF10B981)),
                ] else
                  const Text('Chưa có task nào',
                      style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Key metrics
          Row(
            children: [
              _MetricCard(
                  label: 'Tổng task',
                  value: '$total',
                  color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 12),
              _MetricCard(
                  label: 'Hoàn thành',
                  value: '$done',
                  color: const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricCard(
                  label: 'Quá hạn',
                  value: '$overdue',
                  color: const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _MetricCard(
                  label: 'Đang review',
                  value: '$reviewing',
                  color: const Color(0xFF3B82F6)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider,
      ProjectProvider projectProvider) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? selectedUserId = projectProvider.allUsers.isNotEmpty
        ? projectProvider.allUsers.first.id
        : null;
    String selectedPriority = 'medium';
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161926),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Thêm nhiệm vụ',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DarkTextField(
                      controller: titleCtrl,
                      label: 'Tiêu đề',
                      icon: Icons.task_alt_rounded),
                  const SizedBox(height: 10),
                  _DarkTextField(
                      controller: descCtrl,
                      label: 'Mô tả',
                      icon: Icons.notes_rounded),
                  const SizedBox(height: 10),

                  // Assignee
                  DropdownButtonFormField<String>(
                    value: selectedUserId,
                    dropdownColor: const Color(0xFF1E2235),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Giao cho',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E2235),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    items: projectProvider.allUsers
                        .map((u) =>
                            DropdownMenuItem(value: u.id, child: Text(u.name)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedUserId = val),
                  ),
                  const SizedBox(height: 10),

                  // Priority
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    dropdownColor: const Color(0xFF1E2235),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Độ ưu tiên',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E2235),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    items: ['low', 'medium', 'high', 'critical'].map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: priorityColors[p],
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(p.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedPriority = val ?? 'medium'),
                  ),
                  const SizedBox(height: 10),

                  // Deadline picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null)
                        setModalState(() => selectedDeadline = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1E2235),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.grey, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            'Deadline: ${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Hủy', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isNotEmpty && selectedUserId != null) {
                    final user = projectProvider.allUsers.firstWhere(
                      (u) => u.id == selectedUserId,
                      orElse: () => UserModel(
                          id: '',
                          name: '',
                          email: '',
                          role: 'member',
                          password: ''),
                    );
                    await taskProvider.createTask(
                      title,
                      descCtrl.text.trim(),
                      widget.projectId,
                      selectedUserId!,
                      selectedDeadline,
                      assigneeName: user.name,
                      assigneeAvatar: user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      priority: selectedPriority,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Tạo', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════
// Task Stats Bar
// ════════════════════════════════════════
class _TaskStatsBar extends StatelessWidget {
  final List<Task> tasks;
  const _TaskStatsBar({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final todo = tasks.where((t) => t.status == 'todo').length;
    final doing = tasks.where((t) => t.status == 'doing').length;
    final reviewing = tasks.where((t) => t.status == 'reviewing').length;
    final done = tasks.where((t) => t.status == 'done').length;

    return Row(
      children: [
        _MiniStat(label: 'Todo', value: todo, color: const Color(0xFFEF4444)),
        _MiniStat(label: 'Doing', value: doing, color: const Color(0xFFF59E0B)),
        _MiniStat(
            label: 'Review', value: reviewing, color: const Color(0xFF3B82F6)),
        _MiniStat(label: 'Done', value: done, color: const Color(0xFF10B981)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// Member Dropdown
// ════════════════════════════════════════
class _MemberDropdown extends StatelessWidget {
  final List<UserModel> allUsers;
  final String selectedId;
  final ValueChanged<String> onChanged;
  const _MemberDropdown(
      {required this.allUsers,
      required this.selectedId,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: const Color(0xFF1E2235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: '',
          child: Text('Tất cả thành viên',
              style: TextStyle(
                  color: selectedId.isEmpty
                      ? const Color(0xFF8B5CF6)
                      : Colors.white)),
        ),
        ...allUsers.map((u) => PopupMenuItem(
              value: u.id,
              child: Text(u.name,
                  style: TextStyle(
                      color: u.id == selectedId
                          ? const Color(0xFF8B5CF6)
                          : Colors.white)),
            )),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline,
                color: Color(0xFF8B5CF6), size: 16),
            const SizedBox(width: 8),
            Text(
              selectedId.isEmpty
                  ? 'Tất cả thành viên'
                  : allUsers
                      .firstWhere((u) => u.id == selectedId,
                          orElse: () => UserModel(
                              id: '',
                              name: 'Unknown',
                              email: '',
                              role: 'member',
                              password: ''))
                      .name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// Task Card
// ════════════════════════════════════════
class _TaskCard extends StatelessWidget {
  final Task task;
  final bool isManager;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onDelete;

  const _TaskCard({
    required this.task,
    required this.isManager,
    required this.statusColor,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isReviewing = task.status.toLowerCase() == 'reviewing';
    final isDone = task.status.toLowerCase() == 'done';
    final isOverdue = task.isOverdue();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161926),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Color bar
                Container(
                  width: 4,
                  color: isDone ? Colors.grey.withOpacity(0.3) : statusColor,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + avatar
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  color: isDone ? Colors.grey : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: statusColor.withOpacity(0.2),
                              child: Text(
                                task.assigneeAvatar.isNotEmpty
                                    ? task.assigneeAvatar
                                    : (task.assigneeName.isNotEmpty
                                        ? task.assigneeName[0].toUpperCase()
                                        : '?'),
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(task.description,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],

                        const SizedBox(height: 8),

                        // Status + deadline + actions
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Status chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(task.status.toUpperCase(),
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),

                            // Deadline
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOverdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.calendar_today,
                                  size: 12,
                                  color: isOverdue
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.deadlineFormatted,
                                  style: TextStyle(
                                    color: isOverdue
                                        ? const Color(0xFFEF4444)
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: isOverdue
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isOverdue) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Text('OVERDUE',
                                        style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),

                            // Manager actions
                            if (isManager && isReviewing) ...[
                              GestureDetector(
                                onTap: onReject,
                                child: _ActionBtn(
                                    label: 'Từ chối',
                                    color: Colors.orangeAccent),
                              ),
                              GestureDetector(
                                onTap: onApprove,
                                child: _ActionBtn(
                                    label: 'Duyệt', color: Colors.greenAccent),
                              ),
                            ],

                            // Member: todo -> doing
                            if (!isManager &&
                                task.status.toLowerCase() == 'todo')
                              GestureDetector(
                                onTap: () => Provider.of<TaskProvider>(context,
                                        listen: false)
                                    .updateTaskStatus(task.id, 'doing'),
                                child: _ActionBtn(
                                    label: 'Bắt đầu',
                                    color: const Color(0xFFF59E0B)),
                              ),

                            // Member: doing -> review
                            if (!isManager &&
                                task.status.toLowerCase() == 'doing')
                              GestureDetector(
                                onTap: () => Provider.of<TaskProvider>(context,
                                        listen: false)
                                    .updateTaskStatus(task.id, 'reviewing'),
                                child: _ActionBtn(
                                    label: 'Nộp bài',
                                    color: const Color(0xFF3B82F6)),
                              ),

                            // Delete (Manager only)
                            if (isManager && onDelete != null)
                              GestureDetector(
                                onTap: onDelete,
                                child: _ActionBtn(
                                    label: 'Xóa',
                                    color: const Color(0xFFEF4444)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  const _ActionBtn({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// ════════════════════════════════════════
// Stat Bar (cho tab Thống kê)
// ════════════════════════════════════════
class _StatBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _StatBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
              width: 60,
              child: Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: const Color(0xFF1E2235),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Metric Card
// ════════════════════════════════════════
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161926),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// Dark TextField (dùng chung)
// ════════════════════════════════════════
class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  const _DarkTextField(
      {required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey, size: 18),
        filled: true,
        fillColor: const Color(0xFF1E2235),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
}
