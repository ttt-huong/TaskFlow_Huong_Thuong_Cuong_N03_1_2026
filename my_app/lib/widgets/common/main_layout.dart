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
    this.showImage = false, // Mặc định là không hiện ảnh
    this.studentNames = 'Hường, Thương, Cường',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. HEADER
        Container(
          width: double.infinity,
          height: showImage ? 180 : 80,
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

        // 2. BODY
        Expanded(
          child: Container(color: AppColors.background, child: body),
        ),

        // 3. FOOTER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: AppColors.primary.withOpacity(0.1),
          child: Column(
            children: [
              const Text(
                'Phenikaa University',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Sinh viên: $studentNames',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
