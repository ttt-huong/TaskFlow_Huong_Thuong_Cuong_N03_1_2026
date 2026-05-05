import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// FILE: main_layout.dart
class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showImage;
  final String studentNames;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.showImage = false,
    this.studentNames = 'Hường, Thương, Cường',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // 1. HEADER - Cố định ở trên cùng
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(showImage ? 180 : 80),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            image: showImage
                ? const DecorationImage(
                    image: AssetImage('assets/group_students.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black26,
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: showImage ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),

      // 2. BODY - Phần cuộn được
      body: body,

      // 3. FOOTER - Cố định ở dưới cùng
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        color: Colors.grey[50],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột 1: Logo & Social
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.task_alt, size: 28, color: Colors.black),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.close, size: 16),
                          SizedBox(width: 8),
                          Icon(Icons.camera_alt_outlined, size: 16),
                          SizedBox(width: 8),
                          Icon(Icons.play_circle_outline, size: 16),
                          SizedBox(width: 8),
                          Icon(Icons.business, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                // Cột 2: Nhóm sinh viên
                Expanded(
                  child: _buildFooterColumn('Nhóm sinh viên', [
                    'Trần Thị Thu Hường',
                    'Nguyễn Thị Thương',
                    'Nguyễn Việt Cường',
                  ]),
                ),
                // Cột 3: Explore
                Expanded(
                  child: _buildFooterColumn('Explore', [
                    'Design',
                    'Prototyping',
                    'Development',
                  ]),
                ),
                // Cột 4: Resources
                Expanded(
                  child: _buildFooterColumn('Resources', [
                    'Blog',
                    'Best practices',
                    'Support',
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 TaskFlow Group 03 - Phenikaa University',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              item,
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
