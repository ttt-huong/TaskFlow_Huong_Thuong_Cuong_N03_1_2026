import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/common/app_footer.dart';
import '../../widgets/common/main_layout.dart';

class StatisticsProfileScreen extends StatelessWidget {
  final bool isManager;

  const StatisticsProfileScreen({super.key, required this.isManager});

  Widget _buildDashboardCard(String number, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberProgress(String name, double progress, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(color),
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
        fontSize: 28,
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

  Widget _managerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: const [
              Icon(Icons.workspace_premium, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Manager – Thống kê toàn bộ dự án và hiệu suất nhóm.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildSectionTitle('Thống kê dự án'),
        const SizedBox(height: 12),
        _buildSectionSubtitle('Xem nhanh các chỉ số chính của toàn bộ nhóm và dự án hiện tại.'),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildDashboardCard('9', 'Tổng task', AppColors.text),
            const SizedBox(width: 14),
            _buildDashboardCard('4', 'Hoàn thành', AppColors.done),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildDashboardCard('3', 'Đang làm', AppColors.doing),
            const SizedBox(width: 14),
            _buildDashboardCard('1', 'Quá hạn', AppColors.error),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Tiến độ tổng thể',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Text(
              '44%',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LinearProgressIndicator(
            value: 0.44,
            minHeight: 12,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HIỆU SUẤT THÀNH VIÊN',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              _buildMemberProgress('Văn A', 0.7, '2/3', AppColors.primary),
              _buildMemberProgress('Thị B', 0.5, '2/5', AppColors.doing),
              _buildMemberProgress('Văn C', 0.3, '1/4', AppColors.primaryLight),
              _buildMemberProgress('Thị D', 0.2, '1/5', AppColors.error),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const AppFooter(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _memberView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 90,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'Không có quyền',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Chỉ Manager mới xem được thống kê toàn Project và hiệu suất thành viên.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              '403 - Forbidden',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'THỐNG KÊ',
      showImage: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isManager ? _managerView() : _memberView(),
      ),
    );
  }
}
