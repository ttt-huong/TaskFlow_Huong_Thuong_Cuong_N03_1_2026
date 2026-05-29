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
  const ProjectTaskScreen({super.key, required this.projectId, required this.projectName});

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
  String _selectedFilter = 'Tất cả';
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedCalendarDay;

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
      return Colors.redAccent;
    }
    switch (task.status.toLowerCase()) {
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

  // --- Logic cho Custom Calendar ---
  List<DateTime> _daysInMonthList(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    
    // Tìm ngày đầu tuần của thứ Hai đầu tiên (offset đệm)
    int weekdayOffset = first.weekday - 1; // 0 = Thứ Hai, 6 = Chủ Nhật
    
    List<DateTime> days = [];
    
    // Thêm các ngày trống của tháng trước làm đệm
    for (int i = weekdayOffset; i > 0; i--) {
      days.add(first.subtract(Duration(days: i)));
    }
    
    // Thêm tất cả các ngày trong tháng hiện tại
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
        backgroundColor: const Color(0xFF0F111A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
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
                padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddTaskDialog(context, projectProvider),
                  ),
                ),
              ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF8B5CF6),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Danh sách'),
              Tab(text: 'Lịch biểu'),
            ],
          ),
        ),
        body: taskProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // --- TAB 1: DANH SÁCH NHIỆM VỤ ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thanh Filter ngang
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((tab) {
                              final isSelected = _selectedFilter == tab;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilter = tab),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1E2235),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        isManager
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2235),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Tất cả thành viên',
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              )
                            : const Text(
                                'Chỉ hiển thị công việc giao cho bạn',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: finalFilteredTasks.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Không có công việc nào',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: finalFilteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = finalFilteredTasks[index];
                                    final bool isReviewing = task.status.toLowerCase() == 'reviewing';

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF161926),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.02),
                                          ),
                                        ),
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
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
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
                                                        color: _statusColor(task).withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        task.status.toUpperCase(),
                                                        style: TextStyle(
                                                          color: _statusColor(task),
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),

                                                    // Nút Duyệt / Từ chối cho Manager
                                                    if (isManager && isReviewing) ...[
                                                      GestureDetector(
                                                        onTap: () => taskProvider.updateTaskStatus(task.id, 'doing'),
                                                        child: _buildActionButton('Từ chối', Colors.orangeAccent),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () => taskProvider.updateTaskStatus(task.id, 'done'),
                                                        child: _buildActionButton('Duyệt', Colors.greenAccent),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.blue.withValues(alpha: 0.15),
                                            child: Text(
                                              task.assigneeAvatar.isNotEmpty
                                                  ? task.assigneeAvatar
                                                  : (task.assigneeName.isNotEmpty
                                                      ? task.assigneeName.substring(0, 1).toUpperCase()
                                                      : '?'),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // --- TAB 2: LỊCH BIỂU (CALENDAR VIEW) ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Bộ điều khiển chuyển tháng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                                });
                              },
                            ),
                            Text(
                              'Tháng ${_currentMonth.month} / ${_currentMonth.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Hàng Thứ (Header)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
                            return SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),

                        // Lưới Lịch biểu
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

                              // Lọc công việc trong ngày
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
                                        ? const Color(0xFF8B5CF6)
                                        : (isToday ? const Color(0xFF1E2235) : Colors.transparent),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isToday && !isSelected
                                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.5)
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
                                              ? (isSelected ? Colors.white : (isToday ? const Color(0xFF8B5CF6) : Colors.white))
                                              : Colors.grey.withValues(alpha: 0.4),
                                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Chỉ báo Dots hoặc +N
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
                                                  color: isSelected ? Colors.white : Colors.grey,
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

                        // Danh sách nhiệm vụ trong ngày được chọn
                        const Divider(color: Color(0xFF1E2235), height: 1),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCalendarDay == null
                                    ? 'Chọn một ngày trên lịch'
                                    : 'Nhiệm vụ ngày ${_selectedCalendarDay!.day}/${_selectedCalendarDay!.month}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
                                  child: Text(
                                    'Hãy nhấn vào một ngày để xem danh sách',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                )
                              : () {
                                  final dayTasks = roleFiltered.where((t) => _isSameDay(t.deadline, _selectedCalendarDay!)).toList();
                                  if (dayTasks.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Không có nhiệm vụ nào trong ngày này',
                                        style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: dayTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = dayTasks[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                              child: Text(
                                                task.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
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
                                                color: _statusColor(task).withValues(alpha: 0.12),
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
                                        );
                                    },
                                  );
                                }(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, ProjectProvider projectProvider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedUser = projectProvider.allUsers.isNotEmpty ? projectProvider.allUsers.first.id : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm nhiệm vụ mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedUser,
                    hint: const Text('Giao cho thành viên'),
                    items: projectProvider.allUsers.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Text(u.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedUser = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isNotEmpty && selectedUser != null) {
                      // Tìm user được chọn để lấy tên và avatar
                      final user = projectProvider.allUsers.firstWhere(
                        (u) => u.id == selectedUser,
                        orElse: () => UserModel(id: '', name: 'Unassigned', email: '', role: 'member', password: ''),
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
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
