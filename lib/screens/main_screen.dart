import 'dart:ui';
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
        _NavItem(Icons.group_outlined, Icons.group_rounded, 'Nhóm'),
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
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Load projects and users in the background
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      projectProvider.loadProjects(currentUser);
      projectProvider.loadAllUsers();
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedProjectId;
    String? selectedUserId;
    DateTime? selectedDeadline = DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final projects = projectProvider.projects;
            final users = projectProvider.allUsers;

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
                  const Text(
                    'Tạo nhiệm vụ mới',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Tiêu đề nhiệm vụ',
                      filled: true,
                      fillColor: const Color(0xFFF8F9FD),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Mô tả chi tiết',
                      filled: true,
                      fillColor: const Color(0xFFF8F9FD),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Project dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedProjectId,
                    hint: const Text('Chọn dự án'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FD),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: projects.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setSheetState(() {
                        selectedProjectId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Assignee dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedUserId,
                    hint: const Text('Giao cho thành viên'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FD),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: users.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Text(u.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setSheetState(() {
                        selectedUserId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Deadline row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hạn chót:',
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        label: Text(
                          selectedDeadline == null
                              ? 'Chọn ngày'
                              : '${selectedDeadline!.day.toString().padLeft(2, '0')}/${selectedDeadline!.month.toString().padLeft(2, '0')}/${selectedDeadline!.year}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selectedDeadline ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) {
                            setSheetState(() {
                              selectedDeadline = d;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final desc = descController.text.trim();
                        if (title.isNotEmpty && selectedProjectId != null && selectedUserId != null) {
                          final user = users.firstWhere((u) => u.id == selectedUserId);
                          final assigneeName = user.name;
                          final assigneeAvatar = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

                          await taskProvider.createTask(
                            title,
                            desc,
                            selectedProjectId!,
                            selectedUserId!,
                            selectedDeadline ?? DateTime.now().add(const Duration(days: 3)),
                            assigneeName: assigneeName,
                            assigneeAvatar: assigneeAvatar,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã tạo nhiệm vụ: "$title"'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng điền đầy đủ thông tin'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tạo nhiệm vụ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          pages[_currentIndex < pages.length ? _currentIndex : 0],
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
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                if (user.isManager) {
                  taskProvider.loadAllTasks();
                } else {
                  taskProvider.loadMyTasks(user.id);
                }
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
                          color: active ? AppColors.primary : AppColors.secondaryText,
                          size: 24, // Kích thước icon 24px theo thiết kế
                        ),
                        const SizedBox(height: 2), // Khoảng cách 2px theo thiết kế
                        Text(
                          item.label,
                          style: TextStyle(
                            color: active ? AppColors.primary : AppColors.secondaryText,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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

