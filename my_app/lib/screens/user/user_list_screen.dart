import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/common/main_layout.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'ĐỘI NGŨ',
      showImage: false,
      body: Center(
        child: Text('DANH SÁCH THÀNH VIÊN NHÓM', style: AppTextStyles.body),
      ),
    );
  }
}
