// =============================================================================
// IMPORTS
// =============================================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/common/main_layout.dart';
import '../widgets/common/app_footer.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../core/app_colors.dart';

// =============================================================================
// CLASS: HomeScreen (StatefulWidget)
// =============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// =============================================================================
// CLASS: _HomeScreenState (Main State Implementation)
// =============================================================================
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  
  // =============================================================================
  // 1. STATE PROPERTIES & VARIABLES
  // =============================================================================
  int _activeTab = 0; // 0 = Tổng quan, 1 = Nhiệm vụ của tôi
  String _selectedStatusChip = 'Tất cả';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const String studentName = 'Trần Thị Thu Hường';

  // =============================================================================
  // 2. LIFECYCLE METHODS
  // =============================================================================
  @override
  void initState() {
    super.initState();
    
    // Khởi tạo Animation Controller & Curves
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    // Nạp dữ liệu tự động sau khi giao diện render xong lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      if (user != null) {
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        
        projectProvider.loadProjects(user);
        projectProvider.loadAllUsers();
        if (user.isManager) {
          taskProvider.loadAllTasks();
        } else {
          taskProvider.loadMyTasks(user.id);
        }
      }
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // =============================================================================
  // 3. NAVIGATION & UTILITY METHODS
  // =============================================================================
  void _switchTab(int index) {
    if (_activeTab == index) return;
    setState(() => _activeTab = index);
    _animCtrl.forward(from: 0);
  }

  String _formatCurrentDate(DateTime date) {
    // Dùng intl để định dạng thứ (vi locale fallback thủ công vì không cần generate)
    const weekdays = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    final dayOfWeek = weekdays[date.weekday % 7];
    return '$dayOfWeek, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  // =============================================================================
  // 4. MAIN BUILD METHOD
  // =============================================================================
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isManager = user?.isManager ?? false;

    return MainLayout(
      title: 'TaskFlow',
      showImage: false,
      body: Container(
        color: AppColors.background,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              // Spring scroll physics tưᨎng tự iOS: dùng SpringScrollSimulation
              physics: const _SpringScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(user?.name ?? studentName, user?.role ?? 'member'),
                  const SizedBox(height: 20),
                  _buildModernSegmentControl(),
                  const SizedBox(height: 20),
                  _activeTab == 0
                      ? _buildTabOverview(isManager, authProvider)
                      : _buildTabMyTasks(isManager, authProvider),
                  const SizedBox(height: 24),
                  const AppFooter(),
                  const SizedBox(height: 100), // Khoảng trống tránh đè lên Floating NavBar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================================
  // 5. UI SECTION: HEADER (Greeting, Date & Avatar)
  // =============================================================================
  Widget _buildHeaderSection(String name, String role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Xin chào 👋',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildRoleBadge(role),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrentDate(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildAvatarWidget(name),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    final isManager = role.toLowerCase() == 'manager';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isManager ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isManager ? 'MANAGER 👑' : 'MEMBER 👥',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isManager ? AppColors.primary : AppColors.secondaryText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }

  // =============================================================================
  // 6. UI SECTION: SEGMENT CONTROL (Tabs Selector)
  // =============================================================================
  Widget _buildModernSegmentControl() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
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
        onTap: () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.secondaryText,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================================
  // 7. UI SECTION: TAB 1 - OVERVIEW (Tổng quan)
  // =============================================================================
  Widget _buildTabOverview(bool isManager, AuthProvider authProvider) {
    if (isManager) {
      return _buildManagerOverview();
    } else {
      return _buildMemberOverview(authProvider);
    }
  }

  // -----------------------------------------------------------------------------
  // Tab Tổng quan - Giao diện của MANAGER
  // -----------------------------------------------------------------------------
  Widget _buildManagerOverview() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    final allTasks = taskProvider.tasks;
    final reviewingTasks = allTasks.where((t) => t.status == 'reviewing').toList();
    final doingTasksCount = allTasks.where((t) => t.status == 'doing').length;
    final doneTasksCount = allTasks.where((t) => t.status == 'done').length;

    final featuredTask = reviewingTasks.isNotEmpty ? reviewingTasks.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero: Task cần duyệt tiêu biểu nhất
        _buildSectionTitle('NHIỆM VỤ TIÊU BIỂU'),
        const SizedBox(height: 12),
        featuredTask != null
            ? _buildManagerHeroCard(featuredTask)
            : _buildManagerFallbackHeroCard(),
        const SizedBox(height: 20),

        // Thống kê nhóm
        _buildSectionTitle('THỐNG KÊ NHÓM'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('TỔNG CỘNG', allTasks.length.toString(), AppColors.primary),
            const SizedBox(width: 12),
            _buildStatCard('ĐANG LÀM', doingTasksCount.toString(), AppColors.doing),
            const SizedBox(width: 12),
            _buildStatCard('HOÀN THÀNH', doneTasksCount.toString(), AppColors.done),
          ],
        ),
        const SizedBox(height: 20),

        // Danh sách nhiệm vụ cần duyệt (nếu có)
        if (reviewingTasks.isNotEmpty) ...[
          _buildSectionTitle('ĐANG CHỜ PHÊ DUYỆT (${reviewingTasks.length})'),
          const SizedBox(height: 12),
          ...reviewingTasks.take(3).map((task) => _buildTaskItem(task, true)),
          const SizedBox(height: 20),
        ],

        // Danh sách dự án
        _buildSectionTitle('DANH SÁCH DỰ ÁN'),
        const SizedBox(height: 12),
        projectProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : projectProvider.projects.isEmpty
                ? _buildEmptyState('Chưa có dự án nào')
                : Column(
                    children: projectProvider.projects.take(3).map((p) => _buildProjectCard(p)).toList(),
                  ),
      ],
    );
  }

  // -----------------------------------------------------------------------------
  // Tab Tổng quan - Giao diện của MEMBER
  // -----------------------------------------------------------------------------
  Widget _buildMemberOverview(AuthProvider authProvider) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final myTasks = taskProvider.tasks;

    final doingTasks = myTasks.where((t) => t.status == 'doing').toList();
    final urgentDoing = doingTasks.where((t) => t.isUrgent).toList();
    final todoTasks = myTasks.where((t) => t.status == 'todo').toList();

    // Lựa chọn task Đang làm gấp nhất để làm Hero, nếu không có lấy task Đang làm thường
    final Task? featuredTask = urgentDoing.isNotEmpty 
        ? urgentDoing.first 
        : (doingTasks.isNotEmpty ? doingTasks.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero: Task đang làm quan trọng nhất
        _buildSectionTitle('NHIỆM VỤ ĐANG LÀM'),
        const SizedBox(height: 12),
        featuredTask != null
            ? _buildMemberHeroCard(featuredTask)
            : _buildMemberFallbackHeroCard(),
        const SizedBox(height: 20),

        // Tiến độ cá nhân
        _buildSectionTitle('TIẾN ĐỘ CỦA TÔI'),
        const SizedBox(height: 12),
        _buildPersonalProgressCard(myTasks),
        const SizedBox(height: 20),

        // Task của tôi cần làm mới
        _buildSectionTitle('NHIỆM VỤ CẦN LÀM MỚI'),
        const SizedBox(height: 12),
        todoTasks.isEmpty
            ? _buildEmptyHint('Tuyệt vời! Không có nhiệm vụ cần làm mới.')
            : Column(
                children: todoTasks.take(3).map((task) => _buildTaskItem(task, false)).toList(),
              ),
      ],
    );
  }

  // =============================================================================
  // 8. UI SUBSECTION: MANAGER HERO CARD (Tasks Needing Approval)
  // =============================================================================
  Widget _buildManagerHeroCard(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CẦN PHÊ DUYỆT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (task.isUrgent)
                const Icon(Icons.priority_high_rounded, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20, // Hero title font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Người nộp: ${task.assigneeName}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hạn chót: ${task.deadlineFormatted}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await taskProvider.updateTaskStatus(task.id, 'doing');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Từ chối'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await taskProvider.updateTaskStatus(task.id, 'done');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B5CF6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Duyệt',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagerFallbackHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'HỆ THỐNG',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Không có nhiệm vụ cần duyệt',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20, // Hero title font size
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tuyệt vời! Tất cả các yêu cầu phê duyệt từ các thành viên trong nhóm đều đã được xử lý xong.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // 9. UI SUBSECTION: MEMBER HERO CARD (Active Doing Task)
  // =============================================================================
  Widget _buildMemberHeroCard(Task task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ĐANG LÀM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (task.isUrgent)
                const Icon(Icons.flash_on, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20, // Hero title font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description.isNotEmpty ? task.description : 'Không có mô tả chi tiết.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hạn chót: ${task.deadlineFormatted}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showStatusUpdateSheet(context, task, false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Cập nhật',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberFallbackHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'HÔM NAY',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Không có nhiệm vụ đang làm',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20, // Hero title font size
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bạn đã hoàn thành hoặc chưa bắt đầu nhiệm vụ nào. Hãy nhận việc mới trong tab "Nhiệm vụ của tôi".',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // 10. UI SUBSECTION: COMPACT STATS & PROJECT CARDS
  // =============================================================================
  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12, // caption size
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalProgressCard(List<Task> myTasks) {
    final doneCount = myTasks.where((t) => t.status == 'done').length;
    final totalCount = myTasks.length;
    final double prog = totalCount > 0 ? doneCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
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
              const Text(
                'Tiến độ cá nhân',
                style: TextStyle(
                  fontSize: 16, // title size
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${(prog * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Đã hoàn thành $doneCount trên tổng số $totalCount nhiệm vụ được giao.',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prog,
              backgroundColor: const Color(0xFFE2E8F0),
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final double prog = project.progress > 0 ? project.progress / 100 : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
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
                project.name,
                style: const TextStyle(
                  fontSize: 16, // title size
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${(prog * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prog,
              backgroundColor: const Color(0xFFE2E8F0),
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${project.memberIds.length} thành viên',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              Row(
                children: [
                  _buildProjectStatBadge('Todo', project.todoCount, AppColors.todo),
                  const SizedBox(width: 8),
                  _buildProjectStatBadge('Doing', project.doingCount, AppColors.doing),
                  const SizedBox(width: 8),
                  _buildProjectStatBadge('Done', project.doneCount, AppColors.done),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // =============================================================================
  // 11. UI SECTION: TAB 2 - MY TASKS (Nhiệm vụ của tôi)
  // =============================================================================
  Widget _buildTabMyTasks(bool isManager, AuthProvider authProvider) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;

    // Phân loại: Manager xem tất cả, Member chỉ xem task của mình được gán
    final roleFiltered = isManager
        ? allTasks
        : allTasks.where((task) => task.assignedTo == authProvider.currentUser?.id).toList();

    // Lọc theo chip trạng thái đang chọn
    final filteredTasks = roleFiltered.where((task) {
      if (_selectedStatusChip == 'Tất cả') return true;
      return task.status.toLowerCase() == _selectedStatusChip.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrolling filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['Tất cả', 'Todo', 'Doing', 'Reviewing', 'Done'].map((status) {
              final isSelected = _selectedStatusChip == status;
              return GestureDetector(
                onTap: () => setState(() => _selectedStatusChip = status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    _chipLabel(status),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.secondaryText,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Danh sách task sau lọc
        _buildSectionTitle('DANH SÁCH NHIỆM VỤ (${filteredTasks.length})'),
        const SizedBox(height: 12),
        filteredTasks.isEmpty
            ? _buildEmptyState('Không tìm thấy nhiệm vụ nào')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskItem(filteredTasks[index], isManager);
                },
              ),
      ],
    );
  }

  String _chipLabel(String status) {
    switch (status) {
      case 'Todo':
        return 'Cần làm';
      case 'Doing':
        return 'Đang làm';
      case 'Reviewing':
        return 'Chờ duyệt';
      case 'Done':
        return 'Đã xong';
      default:
        return 'Tất cả';
    }
  }

  // =============================================================================
  // 12. UI SUBSECTION: INDIVIDUAL TASK ITEM CARD
  // =============================================================================
  Widget _buildTaskItem(Task task, bool isManager) {
    final Color sColor = _statusColor(task.status);
    final isOverdue = task.isOverdue();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isOverdue ? AppColors.error.withValues(alpha: 0.08) : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _showStatusUpdateSheet(context, task, isManager),
        leading: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sColor.withValues(alpha: 0.15),
            border: Border.all(color: sColor, width: 2.5),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14, // body size
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              _buildMiniTag(_getStatusLabelVi(task.status), sColor),
              if (isOverdue) ...[
                const SizedBox(width: 6),
                _buildMiniTag('Quá hạn ⚠', AppColors.error),
              ],
              if (isManager && task.assigneeName.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildAssigneeChip(task),
              ],
            ],
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
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
                fontSize: 12, // caption size
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
          fontSize: 12, // caption size
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
            task.assigneeAvatar.isNotEmpty ? task.assigneeAvatar : (task.assigneeName.isNotEmpty ? task.assigneeName[0].toUpperCase() : '?'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          task.assigneeName,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12, // caption size
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // =============================================================================
  // 13. DIALOG SECTION: STATUS UPDATE BOTTOM SHEET
  // =============================================================================
  void _showStatusUpdateSheet(BuildContext context, Task task, bool isManager) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh nắm kéo thả bottom sheet
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Trạng thái hiện tại & Hạn chót
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(task.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusLabelVi(task.status).toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(task.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'Hạn chót: ${task.deadlineFormatted}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tiêu đề & Mô tả nhiệm vụ
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16, // title size
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description.isNotEmpty ? task.description : 'Không có mô tả chi tiết.',
                style: const TextStyle(
                  fontSize: 14, // body size
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tên thành viên thực hiện
              if (task.assigneeName.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.secondaryText),
                    const SizedBox(width: 8),
                    Text(
                      'Người thực hiện: ${task.assigneeName}',
                      style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'CẬP NHẬT TRẠNG THÁI',
                style: TextStyle(
                  fontSize: 12, // caption size
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),

              // -----------------------------------------------------------------
              // Quyền hạn Manager: Phê duyệt / Từ chối / Hủy
              // -----------------------------------------------------------------
              if (isManager) ...[
                if (task.status == 'reviewing') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, color: Colors.orangeAccent),
                          label: const Text('Từ chối', style: TextStyle(color: Colors.orangeAccent, fontSize: 14)),
                          onPressed: () async {
                            await taskProvider.updateTaskStatus(task.id, 'doing');
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orangeAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Duyệt', style: TextStyle(color: Colors.white, fontSize: 14)),
                          onPressed: () async {
                            await taskProvider.updateTaskStatus(task.id, 'done');
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (task.status != 'cancelled' && task.status != 'done' && task.status != 'archived')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                      label: const Text('Hủy nhiệm vụ', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                      onPressed: () async {
                        await taskProvider.updateTaskStatus(task.id, 'cancelled');
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (task.status == 'done')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.archive_outlined, color: Colors.white),
                      label: const Text('Lưu trữ nhiệm vụ', style: TextStyle(color: Colors.white, fontSize: 14)),
                      onPressed: () async {
                        await taskProvider.updateTaskStatus(task.id, 'archived');
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

              // -----------------------------------------------------------------
              // Quyền hạn Member: Todo -> Doing -> Reviewing
              // -----------------------------------------------------------------
              ] else ...[
                if (task.status == 'todo')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: const Text('Bắt đầu làm', style: TextStyle(color: Colors.white, fontSize: 14)),
                      onPressed: () async {
                        await taskProvider.updateTaskStatus(task.id, 'doing');
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                else if (task.status == 'doing')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.pause, color: Colors.grey),
                          label: const Text('Tạm dừng', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          onPressed: () async {
                            await taskProvider.updateTaskStatus(task.id, 'todo');
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          label: const Text('Gửi duyệt', style: TextStyle(color: Colors.white, fontSize: 14)),
                          onPressed: () async {
                            await taskProvider.updateTaskStatus(task.id, 'reviewing');
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (task.status == 'reviewing')
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Nhiệm vụ đang chờ quản lý phê duyệt.',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  )
                else if (task.status == 'done')
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Nhiệm vụ đã hoàn thành xuất sắc!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Không thể thay đổi trạng thái lúc này.',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  // =============================================================================
  // 14. HELPER METHODS & UI UTILITIES
  // =============================================================================
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12, // caption size
        fontWeight: FontWeight.w800,
        color: AppColors.secondaryText,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyHint(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14, // body size
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 28,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 16, // title size
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabelVi(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return 'Chưa làm';
      case 'doing':
        return 'Đang làm';
      case 'reviewing':
        return 'Chờ duyệt';
      case 'done':
        return 'Đã xong';
      case 'cancelled':
        return 'Đã hủy';
      case 'archived':
        return 'Đã lưu';
      default:
        return status.toUpperCase();
    }
  }

  Color _statusColor(String status) {
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
}

// =============================================================================
// SPRING SCROLL PHYSICS — Mô phỏng cuộn lò xo kiểu iOS
// =============================================================================
class _SpringScrollPhysics extends ScrollPhysics {
  const _SpringScrollPhysics({super.parent});

  @override
  _SpringScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SpringScrollPhysics(parent: buildParent(ancestor));
  }

  // Lực lò xo: stiffness cao → cứng hơn, damping cao → tắt nhanh hơn
  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.5,
        stiffness: 150.0,
        damping: 18.0,
      );

  // Cho phép overscroll để có hiệu ứng lò xo kéo giãn
  @override
  double get minFlingVelocity => 50.0;

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        minFlingVelocity *
        (existingVelocity.abs() / minFlingVelocity).clamp(0.0, 1.0);
  }
}

