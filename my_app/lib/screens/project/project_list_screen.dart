import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/common/main_layout.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'DỰ ÁN',
      showImage: false,
      body: Center(
        child: Text('DANH SÁCH DỰ ÁN SẼ HIỂN THỊ TẠI ĐÂY', style: AppTextStyles.body),
      ),
    );
  }
}
