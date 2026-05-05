import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/common/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'TRANG CHỦ',
      showImage: true, 
      body: Center(
        child: Text('CHÀO MỪNG ĐẾN VỚI TASKFLOW', style: AppTextStyles.body),
      ),
    );
  }
}
