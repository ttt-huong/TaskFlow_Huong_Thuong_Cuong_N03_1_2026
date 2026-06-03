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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedCalendarDay;

  static const Map<String, Color> statusColors = {
    'todo': Color(0xFFEF4444),
    'doing': Color(0xFFF59E0B),
    'reviewing': Color(0xFF3B82F6),
    'done': Color(0xFF10B981),
  };

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
    _searchController.dispose();
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
    int offset = first.weekday - 1;
    List<DateTime> days = [];
    for (int i = offset; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }
    for (int i = 0; i < last.day; i++) {
      days.add(first.add(Duration(days: i)));
    }
    return days;
  }

  // Health score
  int _healthScore(List<Task> tasks) {
    if (tasks.isEmpty) return 100;
    final total = tasks.length;
    final done = tasks.where((t) => t.status == 'done').length;
    final overdue = tasks.where((t) => t.isOverdue()).length;
    final reviewing = tasks.where((t) => t.status == 'reviewing').length;
    final doneRate = (done / total) * 70;
    final overduePenalty = (overdue / total) * 30;
    final reviewBonus = (reviewing / total) * 10;
    return (doneRate - overduePenalty + reviewBonus + 30).clamp(0, 100).round();
  }

  Color _healthColor(int score) {
    if (score >= 85) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _healthLabel(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 60) return 'Good';
    return 'Poor';
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

    // Search filter
    List<Task> searchFiltered = _searchQuery.isEmpty
        ? memberFiltered
        : memberFiltered.where((t) {
            final q = _searchQuery.toLowerCase();
            return t.title.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q) ||
                t.assigneeName.toLowerCase().contains(q);
          }).toList();

    // Status filter
    List<Task> finalTasks = _selectedFilter == 'Tất cả'
        ? searchFiltered
        : searchFiltered.where((t) {
            if (_selectedFilter == 'Review') {
              return t.status.toLowerCase() == 'reviewing';
            }
            return t.status.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();

    // Count per status for chips
    int countByStatus(String status) {
      if (status == 'Tất cả') return searchFiltered.length;
      if (status == 'Review') {
        return searchFiltered
            .where((t) => t.status.toLowerCase() == 'reviewing')
            .length;
      }
      return searchFiltered
          .where((t) => t.status.toLowerCase() == status.toLowerCase())
          .length;
    }

    final health = _healthScore(roleFiltered);

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
          // Health score badge
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _healthColor(health).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: _healthColor(health).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      color: _healthColor(health), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '$health · ${_healthLabel(health)}',
                    style: TextStyle(
                        color: _healthColor(health),
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
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
                    projectProvider, finalTasks, roleFiltered, countByStatus),
                _buildCalendarTab(roleFiltered),
                _buildMembersTab(
                    context, isManager, taskProvider, projectProvider),
                _buildStatsTab(taskProvider, roleFiltered, projectProvider),
              ],
            ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TAB 1: DANH SÁCH
  // ══════════════════════════════════════════════════════
  Widget _buildTaskListTab(
    BuildContext context,
    bool isManager,
    TaskProvider taskProvider,
    ProjectProvider projectProvider,
    List<Task> finalTasks,
    List<Task> roleFiltered,
    int Function(String) countByStatus,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats bar
          _TaskStatsBar(tasks: roleFiltered),
          const SizedBox(height: 14),

          // Search
          _TaskSearchBar(
            controller: _searchController,
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 12),

          // Filter chips with count
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((tab) {
                final isSelected = _selectedFilter == tab;
                final count = countByStatus(tab);
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                    child: Text(
                      '$tab ($count)',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Member filter
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
                ? _TaskEmptyState(hasSearch: _searchQuery.isNotEmpty)
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
                        onStatusChange: (newStatus) =>
                            taskProvider.updateTaskStatus(task.id, newStatus),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TAB 2: LỊCH BIỂU
  // ══════════════════════════════════════════════════════
  Widget _buildCalendarTab(List<Task> roleFiltered) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month nav
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
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                .map((d) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ))
                .toList(),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : isToday
                              ? const Color(0xFF1E2235)
                              : Colors.transparent,
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
                                    : isToday
                                        ? const Color(0xFF8B5CF6)
                                        : Colors.white)
                                : Colors.grey.withOpacity(0.3),
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
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
                                Text(
                                  '+${dayTasks.length - 2}',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold),
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

          const Divider(color: Color(0xFF1E2235)),
          const SizedBox(height: 8),

          // Selected day header
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

          // Day task list
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 32)),
                            SizedBox(height: 8),
                            Text(
                              'Không có nhiệm vụ trong ngày này',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      );
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
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                  child: Text(
                                    task.status.toUpperCase(),
                                    style: TextStyle(
                                        color: _statusColor(task),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
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

  // ══════════════════════════════════════════════════════
  // TAB 3: THÀNH VIÊN
  // ══════════════════════════════════════════════════════
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
        final total = userTasks.length;
        final completion = total == 0 ? 0.0 : doneTasks / total;

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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + role
                    Row(
                      children: [
                        Expanded(
                          child: Text(user.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
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
                    const SizedBox(height: 2),
                    Text(user.email,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),

                    // Progress bar
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
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$doneTasks / $total Task',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(completion * 100).toInt()}% hoàn thành',
                      style: const TextStyle(
                          color: Color(0xFF10B981), fontSize: 11),
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

  // ══════════════════════════════════════════════════════
  // TAB 4: THỐNG KÊ
  // ══════════════════════════════════════════════════════
  Widget _buildStatsTab(TaskProvider taskProvider, List<Task> roleFiltered,
      ProjectProvider projectProvider) {
    final total = roleFiltered.length;
    final todo = roleFiltered.where((t) => t.status == 'todo').length;
    final doing = roleFiltered.where((t) => t.status == 'doing').length;
    final reviewing = roleFiltered.where((t) => t.status == 'reviewing').length;
    final done = roleFiltered.where((t) => t.status == 'done').length;
    final overdue = roleFiltered.where((t) => t.isOverdue()).length;
    final score = taskProvider.productivityScore();
    final health = _healthScore(roleFiltered);

    // Top performer
    final members = projectProvider.allUsers;
    UserModel? topPerformer;
    int topDone = 0;
    for (final user in members) {
      final d = roleFiltered
          .where((t) => t.assignedTo == user.id && t.status == 'done')
          .length;
      if (d > topDone) {
        topDone = d;
        topPerformer = user;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Dashboard
          _SectionTitle(title: 'Analytics Dashboard'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                  label: 'Tổng task',
                  value: '$total',
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.task_rounded),
              _MetricCard(
                  label: 'Hoàn thành',
                  value: '$done',
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_rounded),
              _MetricCard(
                  label: 'Quá hạn',
                  value: '$overdue',
                  color: const Color(0xFFEF4444),
                  icon: Icons.warning_rounded),
              _MetricCard(
                  label: 'Đang làm',
                  value: '$doing',
                  color: const Color(0xFFF59E0B),
                  icon: Icons.play_circle_rounded),
            ],
          ),

          const SizedBox(height: 20),

          // Productivity + Health
          Row(
            children: [
              Expanded(
                child: _ScoreCard(
                  title: 'Productivity',
                  score: score,
                  color: taskProvider.productivityColor(),
                  label: taskProvider.productivityLabel(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScoreCard(
                  title: 'Health Score',
                  score: health,
                  color: _healthColor(health),
                  label: _healthLabel(health),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Task breakdown
          _SectionTitle(title: 'Phân bổ trạng thái'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161926),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Top Performer
          if (topPerformer != null) ...[
            _SectionTitle(title: 'Top Performer'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161926),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topPerformer!.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text('$topDone task hoàn thành',
                            style: const TextStyle(
                                color: Color(0xFFF59E0B), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Activity Timeline
          _SectionTitle(title: 'Activity Timeline'),
          const SizedBox(height: 12),
          _ActivityTimeline(tasks: roleFiltered, members: members),

          const SizedBox(height: 20),
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
                    items: ['low', 'medium', 'high', 'critical']
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Row(children: [
                                Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: priorityColors[p],
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(p.toUpperCase()),
                              ]),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedPriority = val ?? 'medium'),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDeadline = picked);
                      }
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
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
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
// Task Search Bar
// ════════════════════════════════════════
class _TaskSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _TaskSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Tìm task, mô tả, người thực hiện...',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded,
            color: Color(0xFF8B5CF6), size: 18),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1E2235),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
class _TaskCard extends StatefulWidget {
  final Task task;
  final bool isManager;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onDelete;
  final Function(String) onStatusChange;

  const _TaskCard({
    required this.task,
    required this.isManager,
    required this.statusColor,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    this.onDelete,
    required this.onStatusChange,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isReviewing = task.status.toLowerCase() == 'reviewing';
    final isDone = task.status.toLowerCase() == 'done';
    final isOverdue = task.isOverdue();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161926),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.statusColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.04),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: widget.statusColor.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    color: isDone
                        ? Colors.grey.withOpacity(0.3)
                        : widget.statusColor,
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
                                backgroundColor:
                                    widget.statusColor.withOpacity(0.2),
                                child: Text(
                                  task.assigneeAvatar.isNotEmpty
                                      ? task.assigneeAvatar
                                      : task.assigneeName.isNotEmpty
                                          ? task.assigneeName[0].toUpperCase()
                                          : '?',
                                  style: TextStyle(
                                      color: widget.statusColor,
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

                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Status chip
                              _StatusChip(
                                  label: task.status.toUpperCase(),
                                  color: widget.statusColor,
                                  isDone: isDone),

                              // Deadline
                              _DeadlineBadge(
                                  date: task.deadlineFormatted,
                                  isOverdue: isOverdue),

                              // Manager actions
                              if (widget.isManager && isReviewing) ...[
                                _ActionBtn(
                                    label: 'Từ chối',
                                    color: Colors.orangeAccent,
                                    onTap: widget.onReject),
                                _ActionBtn(
                                    label: 'Duyệt',
                                    color: Colors.greenAccent,
                                    onTap: widget.onApprove),
                              ],

                              // Member transitions
                              if (!widget.isManager &&
                                  task.status.toLowerCase() == 'todo')
                                _ActionBtn(
                                    label: 'Bắt đầu',
                                    color: const Color(0xFFF59E0B),
                                    onTap: () =>
                                        widget.onStatusChange('doing')),

                              if (!widget.isManager &&
                                  task.status.toLowerCase() == 'doing')
                                _ActionBtn(
                                    label: 'Nộp bài',
                                    color: const Color(0xFF3B82F6),
                                    onTap: () =>
                                        widget.onStatusChange('reviewing')),

                              // Delete
                              if (widget.isManager && widget.onDelete != null)
                                _ActionBtn(
                                    label: 'Xóa',
                                    color: const Color(0xFFEF4444),
                                    onTap: widget.onDelete!),
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
      ),
    );
  }
}

// ════════════════════════════════════════
// Task Empty State
// ════════════════════════════════════════
class _TaskEmptyState extends StatelessWidget {
  final bool hasSearch;
  const _TaskEmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.inbox_rounded,
            color: Colors.grey.withOpacity(0.4),
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            hasSearch ? 'Không tìm thấy task phù hợp' : 'Chưa có task nào',
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch ? 'Thử tìm với từ khóa khác' : 'Nhấn + để thêm task mới',
            style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Activity Timeline
// ════════════════════════════════════════
class _ActivityTimeline extends StatelessWidget {
  final List<Task> tasks;
  final List<UserModel> members;
  const _ActivityTimeline({required this.tasks, required this.members});

  String _userName(String userId) {
    try {
      return members.firstWhere((u) => u.id == userId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final recentDone = tasks.where((t) => t.status == 'done').take(5).toList();
    final recentReview =
        tasks.where((t) => t.status == 'reviewing').take(3).toList();
    final activities = [
      ...recentDone.map((t) => _ActivityItem(
            name: _userName(t.assignedTo),
            action: 'hoàn thành',
            task: t.title,
            time: _timeAgo(t.deadline),
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
          )),
      ...recentReview.map((t) => _ActivityItem(
            name: _userName(t.assignedTo),
            action: 'chuyển sang Review',
            task: t.title,
            time: _timeAgo(t.deadline),
            color: const Color(0xFF3B82F6),
            icon: Icons.rate_review_rounded,
          )),
    ];

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161926),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Chưa có hoạt động nào',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161926),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: activities
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, color: a.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: a.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' ${a.action} ',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: a.task,
                                    style: TextStyle(
                                        color: a.color,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(a.time,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _ActivityItem {
  final String name;
  final String action;
  final String task;
  final String time;
  final Color color;
  final IconData icon;
  const _ActivityItem({
    required this.name,
    required this.action,
    required this.task,
    required this.time,
    required this.color,
    required this.icon,
  });
}

// ════════════════════════════════════════
// Shared Widgets
// ════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16));
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDone;
  const _StatusChip(
      {required this.label, required this.color, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final c = isDone ? Colors.grey : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style:
              TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final String date;
  final bool isOverdue;
  const _DeadlineBadge({required this.date, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today,
          size: 12,
          color: isOverdue ? const Color(0xFFEF4444) : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: TextStyle(
            color: isOverdue ? const Color(0xFFEF4444) : Colors.grey,
            fontSize: 12,
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isOverdue) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('OVERDUE',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 8,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final Color color;
  final String label;
  const _ScoreCard(
      {required this.title,
      required this.score,
      required this.color,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161926),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFF1E2235),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text('$score',
                  style: TextStyle(
                      color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

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
              width: 56,
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161926),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

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
