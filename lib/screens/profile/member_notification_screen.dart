import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/common/main_layout.dart';

class MemberNotificationScreen extends StatelessWidget {
  const MemberNotificationScreen({super.key});

  Widget _buildNotification(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: const TextStyle(
        color: AppColors.secondaryText,
        height: 1.6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'THÔNG BÁO',
      showImage: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông báo thành viên'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Những thông báo mới nhất liên quan đến nhiệm vụ và tiến độ của bạn.'),
            const SizedBox(height: 24),
            _buildNotification(
              Icons.task_alt,
              'Task mới',
              'Bạn vừa được giao task thiết kế màn hình Profile.',
              AppColors.primary,
            ),
            _buildNotification(
              Icons.access_time,
              'Sắp đến hạn',
              'Task Flutter UI còn 1 ngày để hoàn thành.',
              AppColors.doing,
            ),
            _buildNotification(
              Icons.check_circle,
              'Hoàn thành',
              'Bạn đã hoàn thành 2 task trong tuần này.',
              AppColors.done,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}