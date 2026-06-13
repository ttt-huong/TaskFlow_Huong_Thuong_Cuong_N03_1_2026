// =============================================================================
// IMPORTS
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/common/app_footer.dart';
import '../widgets/common/skeleton_loader.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/notification_provider.dart';
import '../core/widgets/offline_banner.dart';
import '../core/app_colors.dart';
import 'project_list_screen.dart';
import 'user_list_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'task_detail_screen.dart';
import 'project_task_screen.dart';

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
  String _searchQuery = ''; // Từ khóa tìm kiếm từ thanh search trên AppBar
  bool _isInitialLoading = true;
  String? _initialLoadError;

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
      _loadInitialData();
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

  String _normalizeSearchText(String value) {
    final lower = value.toLowerCase().trim();
    const accents = {
      '\u00e0': 'a',
      '\u00e1': 'a',
      '\u1ea1': 'a',
      '\u1ea3': 'a',
      '\u00e3': 'a',
      '\u00e2': 'a',
      '\u1ea7': 'a',
      '\u1ea5': 'a',
      '\u1ead': 'a',
      '\u1ea9': 'a',
      '\u1eab': 'a',
      '\u0103': 'a',
      '\u1eb1': 'a',
      '\u1eaf': 'a',
      '\u1eb7': 'a',
      '\u1eb3': 'a',
      '\u1eb5': 'a',
      '\u00e8': 'e',
      '\u00e9': 'e',
      '\u1eb9': 'e',
      '\u1ebb': 'e',
      '\u1ebd': 'e',
      '\u00ea': 'e',
      '\u1ec1': 'e',
      '\u1ebf': 'e',
      '\u1ec7': 'e',
      '\u1ec3': 'e',
      '\u1ec5': 'e',
      '\u00ec': 'i',
      '\u00ed': 'i',
      '\u1ecb': 'i',
      '\u1ec9': 'i',
      '\u0129': 'i',
      '\u00f2': 'o',
      '\u00f3': 'o',
      '\u1ecd': 'o',
      '\u1ecf': 'o',
      '\u00f5': 'o',
      '\u00f4': 'o',
      '\u1ed3': 'o',
      '\u1ed1': 'o',
      '\u1ed9': 'o',
      '\u1ed5': 'o',
      '\u1ed7': 'o',
      '\u01a1': 'o',
      '\u1edd': 'o',
      '\u1edb': 'o',
      '\u1ee3': 'o',
      '\u1edf': 'o',
      '\u1ee1': 'o',
      '\u00f9': 'u',
      '\u00fa': 'u',
      '\u1ee5': 'u',
      '\u1ee7': 'u',
      '\u0169': 'u',
      '\u01b0': 'u',
      '\u1eeb': 'u',
      '\u1ee9': 'u',
      '\u1ef1': 'u',
      '\u1eed': 'u',
      '\u1eef': 'u',
      '\u1ef3': 'y',
      '\u00fd': 'y',
      '\u1ef5': 'y',
      '\u1ef7': 'y',
      '\u1ef9': 'y',
      '\u0111': 'd',
    };

    final buffer = StringBuffer();
    for (final codeUnit in lower.codeUnits) {
      final char = String.fromCharCode(codeUnit);
      buffer.write(accents[char] ?? char);
    }
    return buffer.toString();
  }

  bool _matchesTask(Task task) {
    if (_searchQuery.isEmpty) return true;
    final haystack = _normalizeSearchText([
      task.title,
      task.description,
      task.assigneeName,
      task.status,
      _getStatusLabelVi(task.status),
      task.deadlineFormatted,
    ].join(' '));
    return haystack.contains(_searchQuery);
  }

  bool _matchesProject(ProjectModel project) {
    if (_searchQuery.isEmpty) return true;
    final haystack = _normalizeSearchText([
      project.name,
      project.description,
      project.memberIds.join(' '),
    ].join(' '));
    return haystack.contains(_searchQuery);
  }

  Widget _buildSearchSummary(int count, String label) {
    if (_searchQuery.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tìm thấy $count $label',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInitialData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _initialLoadError = null;
      });
      _animCtrl.forward();
      return;
    }

    setState(() {
      _isInitialLoading = true;
      _initialLoadError = null;
    });

    try {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      await Future.wait([
        projectProvider.loadProjects(user),
        user.isManager ? taskProvider.loadAllTasks() : taskProvider.loadMyTasks(user.id),
      ]);

      if (!mounted) return;
      final projectIds = projectProvider.projects.map((p) => p.id).toList();
      taskProvider.loadProjectStats(projectIds);

      setState(() {
        _isInitialLoading = false;
        _initialLoadError = null;
      });
      _animCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _initialLoadError = 'Không thể tải dữ liệu trang chủ. Vui lòng thử lại.';
      });
    }
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
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final user = authProvider.currentUser;
    final isManager = user?.isManager ?? false;
    final isPageLoading =
        _isInitialLoading || taskProvider.isLoading || projectProvider.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: isPageLoading
            ? _buildInitialLoadingState()
            : _initialLoadError != null
                ? _buildInitialLoadErrorState()
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        physics: const _SpringScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Top Gradient Banner (Grab Mockup style header)
                            _buildGradientHeader(user),
                            
                            // Main content container with padding
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 2. 8 Quick Actions Grid
                                  _buildQuickActionsGrid(context, isManager),
                                  const SizedBox(height: 24),
                                  
                                  // 3. KPI / Points Card
                                  _buildKPICard(context),
                                  const SizedBox(height: 24),
                                  
                                  // 4. Horizontal Banners (Grab Buy Now mockup style)
                                  _buildHorizontalBanners(),
                                  const SizedBox(height: 24),
                                  
                                  // 5. Segment control and Task Lists
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildSectionTitle('DANH SÁCH HOẠT ĐỘNG'),
                                      const OfflineBanner(),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildModernSegmentControl(isManager),
                                  const SizedBox(height: 16),
                                  _activeTab == 0
                                      ? _buildTabOverview(isManager, authProvider)
                                      : _buildTabMyTasks(isManager, authProvider),
                                  const SizedBox(height: 24),
                                  const AppFooter(),
                                ],
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

  Widget _buildInitialLoadingState() {
    return _buildHomeLoadingSkeleton();
  }

  Widget _buildHomeLoadingSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 150, height: 22, borderRadius: 6),
                  SizedBox(height: 8),
                  SkeletonLoader(width: 110, height: 14, borderRadius: 4),
                ],
              ),
              SkeletonLoader(width: 52, height: 52, borderRadius: 18),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 10,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 130, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          const SkeletonProjectList(),
          const SizedBox(height: 20),
          const SkeletonLoader(width: 150, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          const SkeletonTaskList(),
        ],
      ),
    );
  }

  Widget _buildInitialLoadErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              _initialLoadError ?? 'Không thể tải dữ liệu trang chủ.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================================
  // 5. UI SECTION: HEADER (Greeting, Date & Avatar)
  // =============================================================================
  // Old unused header UI methods removed. Greeting header is now managed by _buildGradientHeader.

  // =============================================================================
  // 6. UI SECTION: SEGMENT CONTROL (Tabs Selector)
  // =============================================================================
  Widget _buildModernSegmentControl(bool isManager) {
    const tab1 = 'Tổng quan';
    final tab2 = isManager ? 'Chờ duyệt' : 'Nhiệm vụ của tôi';
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildSegmentItem(0, tab1),
          _buildSegmentItem(1, tab2),
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
      return _buildManagerOverview(isManager);
    } else {
      return _buildMemberOverview(authProvider);
    }
  }

  // Tab Tổng quan - Giao diện của MANAGER
  // -----------------------------------------------------------------------------
  Widget _buildManagerOverview(bool isManager) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    final allTasks = taskProvider.tasks;
    final matchedTasks = allTasks.where(_matchesTask).toList();
    final matchedProjects = projectProvider.projects.where(_matchesProject).toList();
    final visibleTasks = _searchQuery.isEmpty ? allTasks : matchedTasks;
    final reviewingTasks = visibleTasks.where((t) => t.status == 'reviewing').toList();
    final doingTasksCount = allTasks.where((t) => t.status == 'doing').length;
    final doneTasksCount  = allTasks.where((t) => t.status == 'done').length;
    // Đếm số nhân viên duy nhất được gán task (không tính Manager)
    final memberCount = allTasks.map((t) => t.assignedTo).toSet().where((id) => id.isNotEmpty).length;

    final featuredTask = reviewingTasks.isNotEmpty ? reviewingTasks.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchSummary(
          matchedTasks.length + matchedProjects.length,
          'kết quả',
        ),

        // Thống kê 4 ô (lưới 2x2)
        _buildSectionTitle('THỐNG KÊ NHÓM'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('TỔNG CỘNG', allTasks.length.toString(), AppColors.primary),
            const SizedBox(width: 10),
            _buildStatCard('ĐANG LÀM', doingTasksCount.toString(), AppColors.doing),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard('HOÀN THÀNH', doneTasksCount.toString(), AppColors.done),
            const SizedBox(width: 10),
            _buildStatCard('THÀNH VIÊN', memberCount.toString(), const Color(0xFF0EA5E9)),
          ],
        ),
        const SizedBox(height: 20),

        // Hero: Task cần duyệt tiêu biểu nhất
        _buildSectionTitle('CẦN PHÊ DUYỆT GẤP NHẤT'),
        const SizedBox(height: 12),
        featuredTask != null
            ? _buildManagerHeroCard(featuredTask)
            : _buildManagerFallbackHeroCard(),
        const SizedBox(height: 20),

        if (_searchQuery.isNotEmpty) ...[
          _buildSectionTitle('NHIỆM VỤ KHỚP TỪ KHÓA'),
          const SizedBox(height: 12),
          matchedTasks.isEmpty
              ? _buildEmptyHint('Không tìm thấy nhiệm vụ phù hợp.')
              : Column(
                  children: matchedTasks
                      .take(5)
                      .map((task) => _buildManagerTaskRow(task))
                      .toList(),
                ),
          const SizedBox(height: 20),
        ],

        // Danh sách dự án
        _buildSectionTitle('DANH SÁCH DỰ ÁN'),
        const SizedBox(height: 12),
        projectProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : matchedProjects.isEmpty
                ? _buildEmptyState(_searchQuery.isEmpty
                    ? (isManager ? 'Hãy tạo dự án đầu tiên.' : 'Chưa có dự án nào')
                    : 'Không tìm thấy dự án phù hợp.')
                : Column(
                    children: matchedProjects
                        .take(3)
                        .map((p) => _buildProjectCard(p))
                        .toList(),
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
    final matchedTasks = myTasks.where(_matchesTask).toList();

    if (_searchQuery.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchSummary(matchedTasks.length, 'nhiệm vụ'),
          matchedTasks.isEmpty
              ? _buildEmptyHint('Không tìm thấy nhiệm vụ phù hợp.')
              : Column(
                  children: matchedTasks
                      .map((task) => _buildTaskItem(task, false))
                      .toList(),
                ),
        ],
      );
    }

    if (myTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_ind_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bạn chưa có nhiệm vụ nào.',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manager sẽ giao việc cho bạn.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Container(
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
                    onPressed: () {
                      _showRejectDialog(context, taskProvider, task.id);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Từ chối'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await taskProvider.approveTask(task.id);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Đã duyệt nhiệm vụ thành công 🎉'),
                          backgroundColor: AppColors.done,
                        ));
                      }
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
    ),);
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Container(
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
    ),);
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    final taskProvider = Provider.of<TaskProvider>(context);
    final stats = taskProvider.projectStats[project.id] ?? {
      'total': 0,
      'done': 0,
      'progress': 0.0,
      'todo': 0,
      'doing': 0,
      'reviewing': 0
    };
    final double progressPercent = (stats['progress'] as num?)?.toDouble() ?? 0.0;
    final double prog = progressPercent / 100.0;
    final int todoCount = stats['todo'] ?? 0;
    final int doingCount = stats['doing'] ?? 0;
    final int doneCount = stats['done'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectTaskScreen(
              projectId: project.id,
              projectName: project.name,
            ),
          ),
        );
      },
      child: Container(
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
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 16, // title size
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                '${project.memberIds.length} thành viên',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildProjectStatBadge('Todo', todoCount, AppColors.todo),
                  _buildProjectStatBadge('Doing', doingCount, AppColors.doing),
                  _buildProjectStatBadge('Done', doneCount, AppColors.done),
                ],
              ),
            ],
          ),
        ],
      ),
    ),);
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
  // 11. UI SECTION: TAB 2
  //     - Manager: "Chờ duyệt" — hiện task có status=reviewing, nút Duyệt/Từ chối
  //     - Member : "Nhiệm vụ của tôi" — hiện task được gán cho mình
  // =============================================================================
  Widget _buildTabMyTasks(bool isManager, AuthProvider authProvider) {
    return isManager
        ? _buildManagerApprovalTab()
        : _buildMemberTasksTab(authProvider);
  }

  // --------------------------------------------------------------------------
  // Tab 2 dành cho MANAGER: hiện toàn bộ task của team, lọc theo trạng thái
  // --------------------------------------------------------------------------
  Widget _buildManagerApprovalTab() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;

    // Lọc theo chip trạng thái
    final statusFiltered = _selectedStatusChip == 'Tất cả'
        ? allTasks
        : allTasks.where((t) =>
            t.status.toLowerCase() == _selectedStatusChip.toLowerCase()).toList();

    // Lọc theo từ khóa tìm kiếm
    final filteredTasks = statusFiltered.where(_matchesTask).toList();

    final reviewingCount = allTasks.where((t) => t.status == 'reviewing').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner thông báo số task cần duyệt
        if (reviewingCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFED7AA), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.pending_actions_rounded,
                    color: Color(0xFFEA580C), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Có $reviewingCount nhiệm vụ đang chờ bạn phê duyệt!',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Chip lọc trạng thái
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['Tất cả', 'Todo', 'Doing', 'Reviewing', 'Done'].map((s) {
              final sel = _selectedStatusChip == s;
              return GestureDetector(
                onTap: () => setState(() => _selectedStatusChip = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    _chipLabel(s),
                    style: TextStyle(
                      color: sel ? Colors.white : AppColors.secondaryText,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách task
        _buildSearchSummary(filteredTasks.length, 'nhiệm vụ'),
        filteredTasks.isEmpty
            ? _buildEmptyHint(_searchQuery.isNotEmpty
                ? 'Không tìm thấy kết quả khớp.'
                : 'Không có nhiệm vụ nào trong trạng thái này.')
            : Column(
                children: filteredTasks
                    .map((task) => _buildManagerTaskRow(task))
                    .toList(),
              ),
      ],
    );
  }

  /// Card nhiệm vụ dành cho Manager trong tab Chờ duyệt
  Widget _buildManagerTaskRow(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isReviewing = task.status == 'reviewing';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isReviewing
            ? Border.all(color: const Color(0xFFFED7AA), width: 1.5)
            : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Tiêu đề + Badge trạng thái
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(task.status),
            ],
          ),
          const SizedBox(height: 8),
          // Dòng 2: Nhân viên + Hạn
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.secondaryText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.assigneeName.isNotEmpty ? task.assigneeName : 'Chưa gán',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppColors.secondaryText),
              const SizedBox(width: 4),
              Text(
                task.deadlineShort,
                style: TextStyle(
                  fontSize: 12,
                  color: task.isOverdue() ? AppColors.error : AppColors.secondaryText,
                  fontWeight: task.isOverdue() ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
          // Nút Duyệt / Từ chối chỉ hiện khi status = reviewing
          if (isReviewing) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showRejectDialog(context, taskProvider, task.id);
                  },
                  icon: const Icon(Icons.close_rounded, size: 14),
                  label: const Text('Từ chối',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await taskProvider.approveTask(task.id);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Đã duyệt nhiệm vụ thành công 🎉'),
                        backgroundColor: AppColors.done,
                      ));
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: const Text('Duyệt',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.done,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),);
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> colors = {
      'todo': AppColors.todo,
      'doing': AppColors.doing,
      'reviewing': const Color(0xFFEA580C),
      'done': AppColors.done,
      'cancelled': AppColors.grey,
      'archived': AppColors.secondaryText,
    };
    final Map<String, String> labels = {
      'todo': 'Cần làm',
      'doing': 'Đang làm',
      'reviewing': 'Chờ duyệt',
      'done': 'Xong',
      'cancelled': 'Đã huỷ',
      'archived': 'Lưu trữ',
    };
    final color = colors[status] ?? AppColors.secondaryText;
    final label = labels[status] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 2 dành cho MEMBER: hiện task được gán cho mình, lọc theo trạng thái + search
  // --------------------------------------------------------------------------
  Widget _buildMemberTasksTab(AuthProvider authProvider) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;

    // Chỉ hiện task được gán cho Member hiện tại
    final roleFiltered = allTasks
        .where((task) => task.assignedTo == authProvider.currentUser?.id)
        .toList();

    // Lọc theo chip trạng thái
    final statusFiltered = _selectedStatusChip == 'Tất cả'
        ? roleFiltered
        : roleFiltered
            .where((t) =>
                t.status.toLowerCase() == _selectedStatusChip.toLowerCase())
            .toList();

    // Lọc theo từ khóa tìm kiếm
    final filteredTasks = statusFiltered.where(_matchesTask).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chip lọc trạng thái
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['Tất cả', 'Todo', 'Doing', 'Reviewing', 'Done'].map((s) {
              final sel = _selectedStatusChip == s;
              return GestureDetector(
                onTap: () => setState(() => _selectedStatusChip = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    _chipLabel(s),
                    style: TextStyle(
                      color: sel ? Colors.white : AppColors.secondaryText,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách task
        _buildSearchSummary(filteredTasks.length, 'nhiệm vụ'),
        filteredTasks.isEmpty
            ? _buildEmptyHint(_searchQuery.isNotEmpty
                ? 'Không tìm thấy kết quả khớp.'
                : (roleFiltered.isEmpty
                    ? 'Bạn chưa có nhiệm vụ nào.\nManager sẽ giao việc cho bạn.'
                    : 'Không có nhiệm vụ nào trong trạng thái này.'))
            : Column(
                children: filteredTasks
                    .map((task) => _buildTaskItem(task, false))
                    .toList(),
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
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
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
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildMiniTag(_getStatusLabelVi(task.status), sColor),
                if (isOverdue) _buildMiniTag('Quá hạn ⚠', AppColors.error),
                if (isManager && task.assigneeName.isNotEmpty) _buildAssigneeChip(task),
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
        Flexible(
          child: Text(
            task.assigneeName,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12, // caption size
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
                            Navigator.pop(context);
                            _showRejectDialog(context, taskProvider, task.id);
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
                            final success = await taskProvider.approveTask(task.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Đã duyệt nhiệm vụ thành công 🎉'),
                                  backgroundColor: AppColors.done,
                                ));
                              }
                            }
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

  void _showRejectDialog(BuildContext context, TaskProvider taskProvider, String taskId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Từ chối nhiệm vụ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối nhiệm vụ này:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nhập lý do từ chối...',
                hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F9FD),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.secondaryText)),
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
                  content: Text('Vui lòng nhập lý do từ chối!'),
                  backgroundColor: AppColors.error,
                ));
                return;
              }
              Navigator.pop(ctx);
              final success = await taskProvider.rejectTask(taskId, reason);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Đã từ chối nhiệm vụ và chuyển về Cần làm (Todo).'),
                    backgroundColor: AppColors.error,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Lỗi: Không thể từ chối nhiệm vụ!'),
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // =============================================================================
  // REDESIGNED COMPONENTS (Mockup-inspired)
  // =============================================================================

  Widget _buildGradientHeader(dynamic user) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final unreadCount = notificationProvider.unreadCount;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004732), Color(0xFF002E20)], // Forest green background
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Tooltip(
            message: 'Hồ sơ cá nhân',
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.name != null && user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 42,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Colors.black45,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = _normalizeSearchText(value));
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm nhiệm vụ, dự án...',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      cursorColor: const Color(0xFF004732),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isManager) {
    final List<_GridItem> items = [
      _GridItem(
        icon: Icons.assignment_rounded,
        iconColor: AppColors.primary,
        bgColor: AppColors.primary.withValues(alpha: 0.08),
        label: 'Nhiệm vụ',
        onTap: () {
          _switchTab(1);
        },
      ),
      _GridItem(
        icon: Icons.folder_copy_rounded,
        iconColor: Colors.blue.shade600,
        bgColor: Colors.blue.shade50,
        label: 'Dự án',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectListScreen()));
        },
      ),
      _GridItem(
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFE6F4EA),
        label: 'Thành viên',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
        },
      ),
      _GridItem(
        icon: Icons.notifications_active_rounded,
        iconColor: Colors.red.shade600,
        bgColor: Colors.red.shade50,
        label: 'Thông báo',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
        },
      ),
      _GridItem(
        icon: Icons.add_task_rounded,
        iconColor: Colors.purple.shade600,
        bgColor: Colors.purple.shade50,
        label: 'Tạo việc',
        onTap: () {
          if (isManager) {
            _showCreateTaskSheet(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Chỉ Manager mới có quyền tạo nhiệm vụ!'),
              backgroundColor: AppColors.error,
            ));
          }
        },
      ),
      _GridItem(
        icon: Icons.bar_chart_rounded,
        iconColor: Colors.amber.shade700,
        bgColor: Colors.amber.shade50,
        label: 'Báo cáo',
        onTap: () {
          _showStatisticsDialog(context);
        },
      ),
      _GridItem(
        icon: Icons.manage_accounts_rounded,
        iconColor: Colors.teal.shade600,
        bgColor: Colors.teal.shade50,
        label: 'Hồ sơ',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
      _GridItem(
        icon: Icons.grid_view_rounded,
        iconColor: Colors.grey.shade700,
        bgColor: Colors.grey.shade100,
        label: 'Tất cả',
        onTap: () {
          _showAllFeaturesSheet(context, isManager);
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: item.onTap,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: item.iconColor.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(item.icon, color: item.iconColor, size: 28),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPICard(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;
    final doneTasks = allTasks.where((t) => t.status == 'done').length;
    final int kpiPoints = allTasks.isEmpty ? 0 : (doneTasks * 1250) + 124;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Điểm hiệu suất KPI',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$kpiPoints Điểm',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.credit_card_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'TaskCard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBanners() {
    const List<_BannerItem> banners = [
      _BannerItem(
        title: 'Mẹo Pomodoro',
        subtitle: 'Tập trung cao độ trong 25 phút để hoàn thành nhiệm vụ hiệu quả nhất.',
        category: 'Mẹo - TaskFlow',
        colors: [AppColors.primary, AppColors.primaryLight],
        icon: Icons.timer_rounded,
      ),
      _BannerItem(
        title: 'Kế hoạch Tuần',
        subtitle: 'Xây dựng kế hoạch tuần và đặt mức độ ưu tiên cho từng công việc.',
        category: 'Cẩm nang - Planning',
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        icon: Icons.calendar_month_rounded,
      ),
      _BannerItem(
        title: 'Hợp tác Nhóm',
        subtitle: 'Cập nhật tiến độ thường xuyên giúp nhóm hoạt động trơn tru.',
        category: 'Bài viết - Teamwork',
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
        icon: Icons.diversity_3_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Đề xuất cho bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang tải danh sách bài viết đề xuất...')));
              },
              child: const Row(
                children: [
                  Text(
                    'Xem thêm',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: banners.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = banners[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: item.colors.first.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              item.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      item.icon,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 64,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showScanQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 300,
                height: 380,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quét mã QR',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30, width: 2),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black26,
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary, width: 3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const _ScannerLine(),
                          const Icon(Icons.qr_code_scanner_rounded, color: Colors.white24, size: 64),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Đang tìm mã QR công việc...',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Đã nhận mã QR: Phê duyệt nhiệm vụ thành công 🎉'),
                          backgroundColor: AppColors.done,
                        ));
                      },
                      icon: const Icon(Icons.image_rounded, color: AppColors.primary),
                      label: const Text('Chọn từ bộ sưu tập', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPersonalQRDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mã QR của tôi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    color: Colors.grey.shade50,
                    child: GridView.builder(
                      itemCount: 400,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 20),
                      itemBuilder: (context, index) {
                        final bool fill = (index % 3 == 0 && index % 2 != 0) ||
                            (index > 50 && index < 70 && index % 4 == 0) ||
                            (index > 120 && index < 180 && index % 5 == 0) ||
                            (index > 220 && index < 300 && index % 3 == 0) ||
                            (index < 20 || index % 20 == 0 || index % 20 == 19 || index > 380);
                        return Container(
                          color: fill ? AppColors.text : Colors.transparent,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mã số thành viên: TF-9554',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quét mã này để chia sẻ thông tin liên lạc nhanh hoặc gán việc trực tiếp.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final allTasks = taskProvider.tasks;
    
    final todoCount = allTasks.where((t) => t.status == 'todo').length;
    final doingCount = allTasks.where((t) => t.status == 'doing').length;
    final reviewingCount = allTasks.where((t) => t.status == 'reviewing').length;
    final doneCount = allTasks.where((t) => t.status == 'done').length;
    final totalCount = allTasks.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text(
              'Thống kê hiệu quả',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Tổng số nhiệm vụ', totalCount, Colors.grey),
            const Divider(),
            _buildStatRow('Cần làm (Todo)', todoCount, AppColors.todo),
            _buildStatRow('Đang làm (Doing)', doingCount, AppColors.doing),
            _buildStatRow('Chờ duyệt (Reviewing)', reviewingCount, AppColors.reviewing),
            _buildStatRow('Đã xong (Done)', doneCount, AppColors.done),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tỷ lệ hoàn thành', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      '${totalCount > 0 ? (doneCount * 100 / totalCount).round() : 0}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.done),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? doneCount / totalCount : 0,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.done),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllFeaturesSheet(BuildContext context, bool isManager) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tất cả dịch vụ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.text),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildQuickActionItem(context, Icons.assignment_rounded, AppColors.primary, 'Nhiệm vụ', () {
                    Navigator.pop(ctx);
                    _switchTab(1);
                  }),
                  _buildQuickActionItem(context, Icons.folder_copy_rounded, Colors.blue, 'Dự án', () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectListScreen()));
                  }),
                  _buildQuickActionItem(context, Icons.people_alt_rounded, const Color(0xFF10B981), 'Thành viên', () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                  }),
                  _buildQuickActionItem(context, Icons.notifications_active_rounded, Colors.red, 'Thông báo', () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                  }),
                  _buildQuickActionItem(context, Icons.add_task_rounded, Colors.purple, 'Tạo việc', () {
                    Navigator.pop(ctx);
                    if (isManager) {
                      _showCreateTaskSheet(context);
                    }
                  }),
                  _buildQuickActionItem(context, Icons.bar_chart_rounded, Colors.amber.shade700, 'Thống kê', () {
                    Navigator.pop(ctx);
                    _showStatisticsDialog(context);
                  }),
                  _buildQuickActionItem(context, Icons.manage_accounts_rounded, Colors.teal, 'Hồ sơ', () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(BuildContext context, IconData icon, Color color, String label, VoidCallback onTap) {
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTaskSheet(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      projectProvider.loadProjects(currentUser);
      projectProvider.loadAllUsers();
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedProjectId;
    String? selectedUserId;
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 3));
    bool isUrgent = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final projects = projectProvider.projects;
            final allUsers = projectProvider.allUsers;

            final membersOnly = allUsers.where((u) => !u.isManager).toList();

            final assignableUsers = selectedProjectId == null
                ? membersOnly
                : () {
                    final selectedProject = projects.firstWhere(
                      (p) => p.id == selectedProjectId,
                      orElse: () => projects.isEmpty
                          ? throw Exception('no project')
                          : projects.first,
                    );
                    return membersOnly
                        .where((u) => selectedProject.memberIds.contains(u.id))
                        .toList();
                  }();

            if (selectedUserId != null &&
                assignableUsers.every((u) => u.id != selectedUserId)) {
              selectedUserId = null;
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tạo nhiệm vụ mới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sheetLabel('Tiêu đề *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _sheetInputDecoration(
                          hint: 'Nhập tiêu đề nhiệm vụ',
                          icon: Icons.title_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tiêu đề';
                          if (v.trim().length < 3) return 'Tiêu đề quá ngắn (tối thiểu 3 ký tự)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _sheetLabel('Mô tả'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        decoration: _sheetInputDecoration(
                          hint: 'Thêm mô tả chi tiết (tuỳ chọn)',
                          icon: Icons.notes_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sheetLabel('Dự án *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedProjectId,
                        hint: const Text('Chọn dự án', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                        decoration: _sheetInputDecoration(
                          hint: '',
                          icon: Icons.folder_outlined,
                        ),
                        items: projects.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (val) => setSheetState(() {
                          selectedProjectId = val;
                          selectedUserId = null;
                        }),
                        validator: (v) => v == null ? 'Vui lòng chọn dự án' : null,
                      ),
                      const SizedBox(height: 14),
                      _sheetLabel('Giao cho *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedUserId,
                        hint: Text(
                          selectedProjectId == null
                              ? 'Chọn dự án trước'
                              : assignableUsers.isEmpty
                                  ? 'Dự án chưa có thành viên'
                                  : 'Chọn thành viên',
                          style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                        ),
                        decoration: _sheetInputDecoration(
                          hint: '',
                          icon: Icons.person_outline_rounded,
                        ),
                        items: assignableUsers.map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                child: Text(
                                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 180,
                                child: Text(u.name, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        )).toList(),
                        onChanged: selectedProjectId == null
                            ? null
                            : (val) => setSheetState(() => selectedUserId = val),
                        validator: (v) => v == null ? 'Vui lòng chọn người thực hiện' : null,
                      ),
                      const SizedBox(height: 14),
                      _sheetLabel('Hạn chót *'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: sheetContext,
                            initialDate: selectedDeadline,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                            builder: (ctx, child) => Theme(
                              data: Theme.of(ctx).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setSheetState(() => selectedDeadline = d);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.secondaryText),
                              const SizedBox(width: 12),
                              Text(
                                '${selectedDeadline.day.toString().padLeft(2, '0')}/${selectedDeadline.month.toString().padLeft(2, '0')}/${selectedDeadline.year}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFF8F9FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUrgent
                                ? Colors.orange.shade300
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.priority_high_rounded,
                              color: isUrgent ? Colors.orange.shade700 : AppColors.secondaryText,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Nhiệm vụ khẩn cấp',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isUrgent ? Colors.orange.shade700 : AppColors.text,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Switch(
                              value: isUrgent,
                              onChanged: (v) => setSheetState(() => isUrgent = v),
                              activeThumbColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setSheetState(() => isSubmitting = true);

                                  final title = titleController.text.trim();
                                  final desc = descController.text.trim();
                                  final user = allUsers.firstWhere((u) => u.id == selectedUserId!);

                                  await taskProvider.createTask(
                                    title,
                                    desc,
                                    selectedProjectId!,
                                    selectedUserId!,
                                    selectedDeadline,
                                    assigneeName: user.name,
                                    assigneeAvatar: user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    isUrgent: isUrgent,
                                  );

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                            const SizedBox(width: 8),
                                            Flexible(child: Text('Đã tạo: "$title"')),
                                          ],
                                        ),
                                        backgroundColor: AppColors.done,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_task_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tạo nhiệm vụ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _sheetLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }

  static InputDecoration _sheetInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.secondaryText, size: 18),
      filled: true,
      fillColor: const Color(0xFFF8F9FD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
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

// =============================================================================
// HELPER MODELS FOR REDESIGNED HOME SCREEN
// =============================================================================
class _GridItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.onTap,
  });
}

class _BannerItem {
  final String title;
  final String subtitle;
  final String category;
  final List<Color> colors;
  final IconData icon;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.colors,
    required this.icon,
  });
}

// =============================================================================
// SCANNER LINE ANIMATION WIDGET
// =============================================================================
class _ScannerLine extends StatefulWidget {
  const _ScannerLine();

  @override
  State<_ScannerLine> createState() => _ScannerLineState();
}

class _ScannerLineState extends State<_ScannerLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.15, end: 0.85).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, (_animation.value - 0.5) * 2),
          child: Container(
            width: double.infinity,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

