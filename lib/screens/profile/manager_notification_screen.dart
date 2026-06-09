import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/common/main_layout.dart';

class ManagerNotificationScreen extends StatelessWidget {
  const ManagerNotificationScreen({super.key});

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
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
            _buildSectionTitle('Thông báo Manager'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Các thông báo quan trọng nhất cho quyền Manager trong hệ thống TaskFlow.'),
            const SizedBox(height: 24),
            _buildNotification(
              Icons.warning_amber_rounded,
              'Task quá hạn',
              'Có 2 task chưa hoàn thành và cần duyệt gấp.',
              AppColors.error,
            ),
            _buildNotification(
              Icons.person_add_alt_1,
              'Thành viên mới',
              'Người dùng mới đã tham gia team và chờ phân công nhiệm vụ.',
              AppColors.primary,
            ),
            _buildNotification(
              Icons.task_alt,
              'Task hoàn thành',
              'UI Mobile đã được hoàn tất và chờ xác nhận.',
              AppColors.done,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}