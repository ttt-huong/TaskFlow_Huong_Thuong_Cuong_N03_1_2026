import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/common/main_layout.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_seed_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ===== ITEM STATS =====
  Widget buildStatItem(String number, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ===== ITEM OPTION =====
  Widget buildOption(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userName = user?.name ?? 'Chưa Đăng Nhập';
    final userEmail = user?.email ?? '';
    final userRole = user?.role ?? 'member';
    final userAvatarChar = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return MainLayout(
      title: 'HỒ SƠ',
      showImage: false,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFFF5F6FA), // nền sáng
          child: Column(
            children: [
              // ===== AVATAR =====
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFE0E0E0),
                child: Text(
                  userAvatarChar,
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ===== NAME =====
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              // ===== EMAIL =====
              Text(
                userEmail,
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 10),

              // ===== BADGE =====
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: userRole == 'manager' ? Colors.red : Colors.blue),
                ),
                child: Text(
                  userRole.toUpperCase(),
                  style: TextStyle(
                    color: userRole == 'manager' ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== STATS =====
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    buildStatItem('2', 'PROJECTS'),
                    buildStatItem('5', 'TASKS'),
                    buildStatItem('2', 'DONE', color: Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== OPTIONS =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6)
                  ],
                ),
                child: Column(
                  children: [
                    buildOption(Icons.edit, 'Chỉnh sửa thông tin'),
                    const Divider(height: 1),

                    buildOption(
                      Icons.nightlight_round,
                      'Giao diện tối',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                        activeColor: Colors.purple,
                      ),
                    ),
                    const Divider(height: 1),

                    buildOption(Icons.notifications, 'Thông báo'),
                    const Divider(height: 1),

                    buildOption(Icons.lock, 'Đổi mật khẩu'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== DEBUG OPTIONS =====
              if (userRole == 'manager') ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('DEBUG / SEED DATA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        dense: true,
                      ),
                      const Divider(height: 1),
                      buildOption(
                        Icons.add_to_drive,
                        'Seed Firebase Data',
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đang tạo dữ liệu mẫu...')),
                          );
                          final success = await FirebaseSeedData.seedAll();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Tạo dữ liệu thành công!' : 'Tạo dữ liệu thất bại!'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      buildOption(
                        Icons.delete_forever,
                        'Clear Firebase Data',
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đang xóa dữ liệu...')),
                          );
                          final success = await FirebaseSeedData.clearAll();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Xóa dữ liệu thành công!' : 'Xóa dữ liệu thất bại!'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ===== LOGOUT =====
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
