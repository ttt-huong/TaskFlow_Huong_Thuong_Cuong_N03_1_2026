import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/main_layout.dart';
import '../widgets/common/app_footer.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── State chung ───
  int _activeTab = 0; // 0 = Tổng quan, 1 = Nhiệm vụ

  // ── TextField Logic ───
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ───Dropdown/Chips Logic ───
  String _selectedStatusChip = 'Tất cả';

  // ───DatePicker Logic ───
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // ─── Thiết kế hệ màu ───
  static const Color accentColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF818CF8);
  static const String studentName = 'Trần Thị Thu Hường';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<TaskProvider>(context, listen: false).loadMyTasks(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatCurrentDate(DateTime date) {
    const weekdays = [
      'Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'
    ];
    const months = [
      'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4', 'tháng 5', 'tháng 6',
      'tháng 7', 'tháng 8', 'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12'
    ];
    final dayOfWeek = weekdays[date.weekday % 7];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$dayOfWeek, $day $month năm $year';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isManager = user?.isManager ?? false;

    return MainLayout(
      title: 'TaskFlow',
      showImage: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumSearchField(),
                  const SizedBox(height: 24),
                  _buildGreetingSection(user?.name ?? studentName, user?.role ?? 'member'),
                  const SizedBox(height: 24),
                  _buildModernSegmentControl(),
                  const SizedBox(height: 20),
                  IndexedStack(
                    index: _activeTab,
                    children: [
                      _buildTabOverview(authProvider),
                      _buildTabMyTasks(authProvider),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const AppFooter(),
                ],
              ),
            ),
          ),
          if (isManager)
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng thêm task nhanh dành cho Quản lý (Chọn tab Dự án)')),
                  );
                },
                backgroundColor: accentColor,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumSearchField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm nhiệm vụ...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: accentColor,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String name, String role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Xin chào 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 10,
                        color: accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        role == 'manager' ? 'MANAGER 👑' : 'MEMBER 👤',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrentDate(DateTime.now()),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accentColor, secondaryColor],
            ),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSegmentControl() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildSegmentItem(0, 'Tổng quan'),
          _buildSegmentItem(1, 'Nhiệm vụ của tôi'),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(int index, String label) {
    final bool active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? accentColor : Colors.grey[600],
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabOverview(AuthProvider auth) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final memberTasks = taskProvider.tasks;
    final doingTasks = memberTasks.where((t) => t.status == 'doing').toList();
    final featuredTask = doingTasks.isNotEmpty ? doingTasks.first : null;

    final memberTotal = memberTasks.length;
    final memberDoing = doingTasks.length;
    final memberDone = memberTasks.where((t) => t.status == 'done').length;

    final upcomingTasks = memberTasks.where((t) => t.status == 'todo').toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (featuredTask != null) ...[
          _buildSectionTitle('NHIỆM VỤ NỔI BẬT'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.06),
              border: Border.all(color: accentColor, width: 1.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.04),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ĐANG LÀM',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.bolt, color: Colors.amber, size: 22),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  featuredTask.title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.alarm, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Hạn chót: ${featuredTask.deadlineFormatted}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      await taskProvider.updateTaskStatus(featuredTask.id, 'reviewing');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã nộp bài: "${featuredTask.title}"! Đang chờ duyệt.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Nộp bài cho quản lý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],

        _buildSectionTitle('THỐNG KÊ CHI TIẾT'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('TỔNG', memberTotal.toString().padLeft(2, '0'), accentColor),
            const SizedBox(width: 12),
            _buildStatCard('DOING', memberDoing.toString().padLeft(2, '0'), Colors.orange),
            const SizedBox(width: 12),
            _buildStatCard('DONE', memberDone.toString().padLeft(2, '0'), Colors.green),
          ],
        ),
        const SizedBox(height: 28),

        _buildSectionTitle('SẮP ĐẾN HẠN'),
        const SizedBox(height: 12),
        if (upcomingTasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              'Không có nhiệm vụ sắp tới',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          )
        else
          ...upcomingTasks.take(3).map((task) => _buildTaskItem(task.title, task.deadlineFormatted, task.status)),
      ],
    );
  }

  Widget _buildTabMyTasks(AuthProvider auth) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userTasks = taskProvider.tasks;

    final total = userTasks.length;
    final todo = userTasks.where((t) => t.status == 'todo').length;
    final doing = userTasks.where((t) => t.status == 'doing').length;
    final done = userTasks.where((t) => t.status == 'done').length;

    // Lọc theo Tìm kiếm [A] + Status Chips [B] + Hạn chót [C]
    final filteredTasks = userTasks.where((t) {
      final bool matchesSearch = _searchQuery.isEmpty || t.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final bool matchesStatus = _selectedStatusChip == 'Tất cả' || t.status.toLowerCase() == _selectedStatusChip.toLowerCase();
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = t.deadline.year == _selectedDate!.year &&
            t.deadline.month == _selectedDate!.month &&
            t.deadline.day == _selectedDate!.day;
      }
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSmallStatCard('TỔNG', total.toString(), Colors.blue),
            const SizedBox(width: 8),
            _buildSmallStatCard('TODO', todo.toString(), Colors.redAccent),
            const SizedBox(width: 8),
            _buildSmallStatCard('DOING', doing.toString(), Colors.orange),
            const SizedBox(width: 8),
            _buildSmallStatCard('DONE', done.toString(), Colors.green),
          ],
        ),
        const SizedBox(height: 24),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['Tất cả', 'Todo', 'Doing', 'Reviewing', 'Done'].map((status) {
              final isSelected = _selectedStatusChip == status;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatusChip = status;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accentColor : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        _buildModernFilterLabel('LỌC THEO HẠN CHÓT'),
        _buildModernDatePicker(),
        const SizedBox(height: 24),

        _buildSectionTitle('DANH SÁCH NHIỆM VỤ (${filteredTasks.length})'),
        const SizedBox(height: 12),

        if (filteredTasks.isEmpty)
          _buildEmptyState()
        else
          ...filteredTasks.map((t) => InkWell(
            onTap: () async {
              if (t.status == 'todo') {
                await taskProvider.updateTaskStatus(t.id, 'doing');
              } else if (t.status == 'doing') {
                await taskProvider.updateTaskStatus(t.id, 'reviewing');
              }
            },
            child: _buildTaskItem(t.title, t.deadlineFormatted, t.status),
          )),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String deadline, String status) {
    final Color sColor = _statusColor(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: sColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: sColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            deadline,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildModernDatePicker() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        if (d != null) {
          setState(() {
            _selectedDate = d;
            _dateController.text =
                '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
          });
        }
      },
      decoration: InputDecoration(
        hintText: 'Chọn ngày deadline...',
        prefixIcon: const Icon(
          Icons.calendar_today,
          size: 18,
          color: accentColor,
        ),
        suffixIcon: _selectedDate != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() {
                  _selectedDate = null;
                  _dateController.clear();
                }),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'Không có kết quả',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return Colors.redAccent;
      case 'doing':
        return Colors.orange;
      case 'reviewing':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
