import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/common/main_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'HỒ SƠ',
      showImage: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            const Text('Người dùng TaskFlow', style: AppTextStyles.h2),
            const Divider(height: 40),

            // Phần gộp từ trang About (Bài tập tuần 4)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thành viên nhóm:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Trần Thị Thu Hường'),
                  Text('• Nguyễn Thị Thương'),
                  Text('• Nguyễn Việt Cường'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
