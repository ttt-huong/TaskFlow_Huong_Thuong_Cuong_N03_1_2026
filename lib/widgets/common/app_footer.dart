import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Logo + Columns ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 400 ? MediaQuery.of(context).size.width - 40 : 400,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Cột 1: Logo & Social
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.task_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TaskFlow',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.text,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Quản lý dự án\ntối giản & hiệu quả',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Social icons
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _socialIcon(Icons.facebook_rounded),
                        _socialIcon(Icons.camera_alt_outlined),
                        _socialIcon(Icons.play_circle_outline_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Cột 2: Nhóm sinh viên
              Expanded(
                flex: 2,
                child: _buildFooterColumn('NHÓM SV', [
                  'Trần Thị Thu Hường',
                  'Nguyễn Thị Thương',
                  'Nguyễn Việt Cường',
                ]),
              ),
              // Cột 3: Explore
              Expanded(
                child: _buildFooterColumn('KHÁM PHÁ', [
                  'Tính năng',
                  'Hướng dẫn',
                  'Hỗ trợ',
                ]),
              ),
              ],
            ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Divider ──
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 14),

          // ── Copyright ──
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                '© 2026 TaskFlow · Nhóm 03',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 14, color: AppColors.secondaryText),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 9,
            color: AppColors.secondaryText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              item,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
