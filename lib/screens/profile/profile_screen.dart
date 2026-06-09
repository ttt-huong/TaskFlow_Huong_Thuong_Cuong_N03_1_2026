import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_footer.dart';
import '../../widgets/common/main_layout.dart';
import '../edit_profile_screen.dart';
import 'manager_notification_screen.dart';
import 'member_management_screen.dart';
import 'member_notification_screen.dart';
import 'member_task_screen.dart';
import 'statistics_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(bool isManager) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isManager ? AppColors.primary.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isManager ? 'MANAGER' : 'MEMBER',
        style: TextStyle(
          color: isManager ? AppColors.primary : AppColors.secondaryText,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
border: Border.all(
  color: color.withOpacity(0.15),
),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }

  Widget _buildThemeModeRow() {
    return _buildOptionRow(
      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      isDarkMode ? 'Dark' : 'Light',
      () {
        setState(() {
          isDarkMode = !isDarkMode;
        });
      },
      trailing: Switch.adaptive(
        value: isDarkMode,
        activeColor: AppColors.primary,
        onChanged: (value) {
          setState(() {
            isDarkMode = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final name = currentUser?.name ?? 'Tran Thi B';
    final email = currentUser?.email ?? 'b@gmail.com';
    final bool isManager = currentUser?.isManager ?? false;

    return MainLayout(
      title: 'HỒ SƠ',
      showImage: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF8FAFF),
        Color(0xFFEFF4FF),
      ],
    ),
    borderRadius: BorderRadius.circular(30),

    border: Border.all(
      color: AppColors.primary.withOpacity(0.15),
      width: 1.5,
    ),

    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.15),
        blurRadius: 30,
        spreadRadius: 3,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.8),
        blurRadius: 10,
        offset: const Offset(-4, -4),
      ),
    ],
  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
  padding: const EdgeInsets.all(3),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: AppColors.primary,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.25),
        blurRadius: 12,
      ),
    ],
  ),
  child: const CircleAvatar(
    radius: 38,
    backgroundImage: NetworkImage(
      'https://i.pinimg.com/736x/13/ff/77/13ff77bf458254385bc96c3fd18d3cc7.jpg',
    ),
  ),
),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
  name,
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  ),
),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard('Dự án', '2', AppColors.primary),
                      const SizedBox(width: 12),
                      _buildStatCard('Task', '5', AppColors.doing),
                      const SizedBox(width: 12),
                      _buildStatCard('Hoàn thành', '2', AppColors.done),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Tùy chọn'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildOptionRow(
                    Icons.edit,
                    'Chỉnh sửa thông tin',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildThemeModeRow(),
                  const Divider(height: 1),
                  if (isManager) ...[
                    _buildOptionRow(
                      Icons.bar_chart,
                      'Thống kê',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StatisticsProfileScreen(isManager: isManager),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildOptionRow(
                      Icons.notifications_active,
                      'Thông báo quản lý',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerNotificationScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildOptionRow(
                      Icons.group,
                      'Quản lý thành viên',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MemberManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    _buildOptionRow(
                      Icons.notifications,
                      'Thông báo cá nhân',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MemberNotificationScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildOptionRow(
                      Icons.task,
                      'Task của tôi',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MemberTaskScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withOpacity(0.85)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const AppFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}
