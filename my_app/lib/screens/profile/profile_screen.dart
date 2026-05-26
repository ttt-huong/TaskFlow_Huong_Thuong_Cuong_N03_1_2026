import 'package:flutter/material.dart';
import '../../widgets/common/main_layout.dart';
import 'statistics_profile_screen.dart';
import 'edit_profile_screen.dart';
import 'manager_notification_screen.dart';
import 'member_management_screen.dart';
import 'member_notification_screen.dart';
import 'member_task_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // ===== DATA =====
  String selectedRole = "EMPLOYEE";

  String name = 'Tran Thi B';
  String email = 'b@gmail.com';
  String role = "member";

  // ===== STATS =====
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

  // ===== OPTION =====
  Widget buildOption(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),

      title: Text(title),

      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right,
            color: Colors.black54,
          ),

      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'HỒ SƠ',
      showImage: false,

      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFFF5F6FA),

          child: Column(
            children: [

              // ===== AVATAR =====
              const CircleAvatar(
                radius: 50,

                backgroundImage: NetworkImage(
                  'https://i.pinimg.com/736x/13/ff/77/13ff77bf458254385bc96c3fd18d3cc7.jpg',
                ),
              ),

              const SizedBox(height: 16),

              // ===== NAME =====
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // ===== EMAIL =====
              Text(
                email,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 10),

              // ===== ROLE =====
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue),
                ),

                child: Text(
  role == "manager" ? "MANAGER" : "MEMBER",
  style: const TextStyle(
    color: Colors.blue,
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
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    buildStatItem('2', 'PROJECTS'),

                    buildStatItem('5', 'TASKS'),

                    buildStatItem(
                      '2',
                      'DONE',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== MENU =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    ),
                  ],
                ),

                child: Column(
  children: [

    // ===== EDIT PROFILE =====
    buildOption(
      Icons.edit,
      'Chỉnh sửa thông tin',

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const EditProfileScreen(),
          ),
        );
      },
    ),

    const Divider(height: 1),

    // ===== MANAGER =====
    if (role == "manager") ...[

      buildOption(
        Icons.bar_chart,
        'Thống kê',

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StatisticsProfileScreen(
                role: role,
              ),
            ),
          );
        },
      ),

      const Divider(height: 1),

     buildOption(
  Icons.notifications_active,
  'Thông báo quản lý',

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ManagerNotificationScreen(),
      ),
    );
  },
),
      const Divider(height: 1),

      buildOption(
  Icons.group,
  'Quản lý thành viên',

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MemberManagementScreen(),
      ),
    );
  },
),
    ],

    // ===== MEMBER =====
    if (role == "member") ...[

      buildOption(
  Icons.notifications,
  'Thông báo cá nhân',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MemberNotificationScreen(),
      ),
    );
  },
),

      const Divider(height: 1),

      buildOption(
  Icons.task,
  'Task của tôi',
  onTap: () {
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

              // ===== LOGOUT =====
              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
                    ),

                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),

                  onPressed: () {},

                  child: const Text(
                    'Đăng xuất',

                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // ===== FOOTER =====
              _buildModernFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ===== FOOTER =====
  Widget _buildModernFooter() {
    return Column(
      children: [

        const Divider(
          height: 1,
          color: Color(0xFFF1F5F9),
        ),

        const SizedBox(height: 40),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== LEFT ICON =====
            Expanded(
              flex: 2,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Icon(
                    Icons.task_alt,
                    size: 28,
                    color: Colors.black,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: const [

                      Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black54,
                      ),

                      SizedBox(width: 12),

                      Icon(
                        Icons.camera_alt_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),

                      SizedBox(width: 12),

                      Icon(
                        Icons.play_circle_outline,
                        size: 18,
                        color: Colors.black54,
                      ),

                      SizedBox(width: 12),

                      Icon(
                        Icons.business_center_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===== COLUMN 1 =====
            Expanded(
              child: _buildFooterLinkColumn(
                'Use cases',
                [
                  'UI design',
                  'UX design',
                  'Wireframing',
                ],
              ),
            ),

            // ===== COLUMN 2 =====
            Expanded(
              child: _buildFooterLinkColumn(
                'Explore',
                [
                  'Design',
                  'Prototyping',
                  'Systems',
                ],
              ),
            ),

            // ===== COLUMN 3 =====
            Expanded(
              child: _buildFooterLinkColumn(
                'Resources',
                [
                  'Blog',
                  'Best practices',
                  'Support',
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 50),

        Text(
          '© 2026 TaskFlow Group 03 — Phenikaa University',

          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ===== FOOTER COLUMN =====
  Widget _buildFooterLinkColumn(
    String title,
    List<String> links,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 16),

        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),

            child: Text(
              link,

              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}