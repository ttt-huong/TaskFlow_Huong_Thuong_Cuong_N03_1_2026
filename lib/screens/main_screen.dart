import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../providers/connectivity_provider.dart';
import 'home_screen.dart';
import 'project_list_screen.dart';
import 'user_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _wasOnline = true; // theo dõi trạng thái trước để phát hiện reconnect

  final List<Widget> _managerPages = [
    const HomeScreen(),
    const ProjectListScreen(),
    const UserListScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _memberPages = [
    const HomeScreen(),
    const ProjectListScreen(),
    const ProfileScreen(),
  ];

  List<_NavItem> _getNavItems(String role) {
    if (role == 'manager') {
      return const [
        _NavItem(Icons.home_outlined, Icons.home_rounded, 'Trang chủ'),
        _NavItem(Icons.folder_outlined, Icons.folder_rounded, 'Dự án'),
        _NavItem(Icons.group_outlined, Icons.group_rounded, 'Thành viên'),
        _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Hồ sơ'),
      ];
    } else {
      return const [
        _NavItem(Icons.home_outlined, Icons.home_rounded, 'Trang chủ'),
        _NavItem(Icons.folder_outlined, Icons.folder_rounded, 'Dự án'),
        _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Hồ sơ'),
      ];
    }
  }

  void _showCreateTaskSheet(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load dự án và danh sách user
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

            // Lọc assignee: chỉ hiện Member (không hiện Manager)
            // và lọc thêm theo thành viên của dự án đã chọn
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

            // Nếu user được chọn không thuộc dự án mới → reset
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
                      // Handle bar
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

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.task_alt_rounded,
                                color: AppColors.primary, size: 20),
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

                      // ── Tiêu đề ──
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
                          if (v == null || v.trim().isEmpty)
                            return 'Vui lòng nhập tiêu đề';
                          if (v.trim().length < 3)
                            return 'Tiêu đề quá ngắn (tối thiểu 3 ký tự)';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Mô tả ──
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

                      // ── Dự án ──
                      _sheetLabel('Dự án *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedProjectId,
                        hint: const Text('Chọn dự án',
                            style: TextStyle(
                                color: AppColors.secondaryText, fontSize: 14)),
                        decoration: _sheetInputDecoration(
                          hint: '',
                          icon: Icons.folder_outlined,
                        ),
                        items: projects
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) => setSheetState(() {
                          selectedProjectId = val;
                          selectedUserId = null; // reset assignee khi đổi dự án
                        }),
                        validator: (v) =>
                            v == null ? 'Vui lòng chọn dự án' : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Giao cho ──
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
                          style: const TextStyle(
                              color: AppColors.secondaryText, fontSize: 14),
                        ),
                        decoration: _sheetInputDecoration(
                          hint: '',
                          icon: Icons.person_outline_rounded,
                        ),
                        items: assignableUsers
                            .map((u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppColors.primary
                                            .withValues(alpha: 0.15),
                                        child: Text(
                                          u.name.isNotEmpty
                                              ? u.name[0].toUpperCase()
                                              : '?',
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
                                        child: Text(u.name,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: selectedProjectId == null
                            ? null
                            : (val) =>
                                setSheetState(() => selectedUserId = val),
                        validator: (v) =>
                            v == null ? 'Vui lòng chọn người thực hiện' : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Deadline ──
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
                          if (d != null)
                            setSheetState(() => selectedDeadline = d);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 18, color: AppColors.secondaryText),
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
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.secondaryText, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Mức độ ưu tiên ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
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
                              color: isUrgent
                                  ? Colors.orange.shade700
                                  : AppColors.secondaryText,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Nhiệm vụ khẩn cấp',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isUrgent
                                      ? Colors.orange.shade700
                                      : AppColors.text,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Switch(
                              value: isUrgent,
                              onChanged: (v) =>
                                  setSheetState(() => isUrgent = v),
                              activeThumbColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Nút tạo ──
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
                                  final user = allUsers.firstWhere(
                                      (u) => u.id == selectedUserId!);

                                  await taskProvider.createTask(
                                    title,
                                    desc,
                                    selectedProjectId!,
                                    selectedUserId!,
                                    selectedDeadline,
                                    assigneeName: user.name,
                                    assigneeAvatar: user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
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
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 18),
                                            const SizedBox(width: 8),
                                            Flexible(
                                                child:
                                                    Text('Đã tạo: "$title"')),
                                          ],
                                        ),
                                        backgroundColor: AppColors.done,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.6),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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

  // ── Helpers dùng trong sheet ──
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

  static InputDecoration _sheetInputDecoration(
      {required String hint, required IconData icon}) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.currentUser?.role ?? 'member';
    final pages = role == 'manager' ? _managerPages : _memberPages;
    final navItems = _getNavItems(role);
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    // Hiển thị SnackBar khi mạng vừa trở lại
    if (isOnline && !_wasOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Đã kết nối lại — đang đồng bộ dữ liệu...'),
                ],
              ),
              backgroundColor: const Color(0xFF16A34A),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    }
    _wasOnline = isOnline;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Page content ──
          pages[_currentIndex],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: role == 'manager'
          ? Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _showCreateTaskSheet(context),
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: _CustomBottomNavBar(
        items: navItems,
        currentIndex: _currentIndex,
        onTap: (i) {
          if (_currentIndex != i) {
            setState(() => _currentIndex = i);
            if (i == 0) {
              final user = authProvider.currentUser;
              if (user != null) {
                final taskProvider =
                    Provider.of<TaskProvider>(context, listen: false);
                taskProvider.loadHomeTasks(user);
              }
            }
          }
        },
        hasNotch: role == 'manager',
      ),
    );
  }
}

// ─── Data class ───
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

// ─── Custom NavBar Widget ───
class _CustomBottomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasNotch;

  const _CustomBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.hasNotch,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: hasNotch ? const CircularNotchedRectangle() : null,
      notchMargin: 10,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: () {
            final List<Widget> children = [];
            final int mid = (items.length / 2).floor();
            for (int i = 0; i < items.length; i++) {
              if (hasNotch && i == mid) {
                // Reserve center gap for FAB
                children.add(const SizedBox(width: 48));
              }
              final item = items[i];
              final active = currentIndex == i;
              children.add(
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          active ? item.activeIcon : item.icon,
                          color: active
                              ? AppColors.primary
                              : AppColors.secondaryText,
                          size: 24, // Kích thước icon 24px theo thiết kế
                        ),
                        const SizedBox(
                            height: 2), // Khoảng cách 2px theo thiết kế
                        Text(
                          item.label,
                          style: TextStyle(
                            color: active
                                ? AppColors.primary
                                : AppColors.secondaryText,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12, // Kích thước font 12px theo thiết kế
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return children;
          }(),
        ),
      ),
    );
  }
}
