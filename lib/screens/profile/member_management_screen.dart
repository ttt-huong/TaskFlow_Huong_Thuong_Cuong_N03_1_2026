import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/common/main_layout.dart';

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key});

  Widget _buildMember(
    String name,
    String role,
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
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.more_vert, color: AppColors.secondaryText),
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
      title: 'QUẢN LÝ',
      showImage: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Quản lý thành viên'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Danh sách thành viên trong nhóm và vai trò đảm nhiệm của họ.'),
            const SizedBox(height: 24),
            _buildMember(
              'Trần Thị B',
              'Manager',
              AppColors.primary,
            ),
            _buildMember(
              'Nguyễn Văn A',
              'Developer',
              AppColors.doing,
            ),
            _buildMember(
              'Lê Văn C',
              'Designer',
              AppColors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }
}