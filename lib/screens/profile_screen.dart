import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/main_layout.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../core/app_colors.dart';
import '../services/firebase_seed_data.dart';
import 'edit_profile_screen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final user = authProvider.currentUser;
    final userName = user?.name ?? 'Chưa Đăng Nhập';
    final userEmail = user?.email ?? '';
    final userRole = user?.role ?? 'member';
    final userAvatarChar = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    final projectsCount = projectProvider.projects.length;
    final totalTasks = taskProvider.tasks.length;
    final doneTasks = taskProvider.tasks.where((t) => t.status == 'done').length;

    return MainLayout(
      title: 'HỒ SƠ',
      showImage: false,
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              // ===== HEADER GRADIENT =====
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.25),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          userAvatarChar,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        userRole == 'manager' ? '👑  Quản lý' : '👤  Thành viên',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== STATS =====
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildStatItem(context, projectsCount.toString(), 'Dự án', Icons.folder_outlined, AppColors.primary),
                      _buildDivider(),
                      _buildStatItem(context, totalTasks.toString(), 'Nhiệm vụ', Icons.task_alt_outlined, AppColors.doing),
                      _buildDivider(),
                      _buildStatItem(context, doneTasks.toString(), 'Hoàn thành', Icons.check_circle_outline, AppColors.done),
                    ],
                  ),
                ),
              ),

              // ===== OPTIONS =====
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Tài khoản'),
                    const SizedBox(height: 10),
                    _buildOptionsCard([
                      _buildOption(
                        icon: Icons.edit_outlined,
                        title: 'Chỉnh sửa thông tin',
                        subtitle: 'Cập nhật tên & mật khẩu',
                        iconColor: AppColors.primary,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                          // updated == true nếu user đã lưu thay đổi tên
                          if (updated == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Hồ sơ đã được cập nhật!'),
                                backgroundColor: AppColors.done,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildOption(
                        icon: Icons.notifications_outlined,
                        title: 'Thông báo',
                        subtitle: 'Xem tất cả thông báo',
                        iconColor: AppColors.reviewing,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen()),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    _sectionLabel('Giao diện'),
                    const SizedBox(height: 10),
                    _buildOptionsCard([
                      _buildOption(
                        icon: Icons.nightlight_round,
                        title: 'Giao diện tối',
                        subtitle: 'Đang được phát triển',
                        iconColor: Colors.deepPurple,
                        trailing: Switch(
                          value: false,
                          onChanged: (_) => _showDarkModeDialog(context),
                          activeThumbColor: Colors.deepPurple,
                        ),
                        onTap: () => _showDarkModeDialog(context),
                      ),
                    ]),

                    // ===== DEBUG (Manager only) =====
                    if (userRole == 'manager') ...[
                      const SizedBox(height: 16),
                      _sectionLabel('Dữ liệu (Debug)'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildOption(
                              icon: Icons.add_to_drive_outlined,
                              title: 'Seed Firebase Data',
                              subtitle: 'Tạo dữ liệu mẫu',
                              iconColor: Colors.orange,
                              onTap: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đang tạo dữ liệu mẫu...')),
                                );
                                final success = await FirebaseSeedData.seedAll();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? 'Tạo dữ liệu thành công!' : 'Tạo dữ liệu thất bại!'),
                                      backgroundColor: success ? AppColors.done : AppColors.error,
                                    ),
                                  );
                                }
                              },
                            ),
                            const Divider(height: 1, indent: 56),
                            _buildOption(
                              icon: Icons.delete_forever_outlined,
                              title: 'Clear Firebase Data',
                              subtitle: 'Xóa toàn bộ dữ liệu',
                              iconColor: AppColors.error,
                              onTap: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đang xóa dữ liệu...')),
                                );
                                final success = await FirebaseSeedData.clearAll();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? 'Xóa dữ liệu thành công!' : 'Xóa dữ liệu thất bại!'),
                                      backgroundColor: success ? AppColors.done : AppColors.error,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ===== LOGOUT =====
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Đăng xuất'),
                              content: const Text('Bạn có chắc muốn đăng xuất khỏi ứng dụng?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy', style: TextStyle(color: AppColors.secondaryText)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 56,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.secondaryText,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildOptionsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }

  void _showDarkModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.construction_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Đang phát triển'),
          ],
        ),
        content: const Text(
          'Tính năng giao diện tối đang được phát triển và sẽ ra mắt trong phiên bản tới. Hiện tại ứng dụng chỉ hỗ trợ giao diện sáng.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
