import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/common/main_layout.dart';

class MemberTaskScreen extends StatelessWidget {
  const MemberTaskScreen({super.key});

  Widget _buildTaskCard(
    String title,
    String status,
    Color color,
    double progress,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}% hoàn thành',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'TASK CỦA TÔI',
      showImage: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xem các task hiện tại và theo dõi tiến độ hoàn thành của bạn.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _buildTaskCard(
              'Thiết kế màn hình Profile',
              'Đang làm',
              AppColors.doing,
              0.6,
            ),
            _buildTaskCard(
              'Hoàn thiện giao diện thống kê',
              'Hoàn thành',
              AppColors.done,
              1.0,
            ),
            _buildTaskCard(
              'Kiểm tra lỗi giao diện',
              'Chưa làm',
              AppColors.error,
              0.2,
            ),
          ],
        ),
      ),
    );
  }
}