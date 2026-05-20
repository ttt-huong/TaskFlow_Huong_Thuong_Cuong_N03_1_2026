import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF6366F1); // Modern Premium Indigo

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột 1: Logo & Social
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.task_alt, size: 22, color: brandColor),
                        SizedBox(width: 6),
                        Text(
                          'TaskFlow',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.facebook, size: 16, color: Colors.black54),
                        SizedBox(width: 12),
                        Icon(Icons.camera_alt_outlined, size: 16, color: Colors.black54),
                        SizedBox(width: 12),
                        Icon(Icons.play_circle_outline, size: 16, color: Colors.black54),
                        SizedBox(width: 12),
                        Icon(Icons.business_center_outlined, size: 16, color: Colors.black54),
                      ],
                    ),
                  ],
                ),
              ),
              // Cột 2: Nhóm sinh viên
              Expanded(
                flex: 2,
                child: _buildFooterColumn('NHÓM SINH VIÊN', [
                  'Trần Thị Thu Hường',
                  'Nguyễn Thị Thương',
                  'Lê Văn Cường',
                ]),
              ),
              // Cột 3: Explore
              Expanded(
                child: _buildFooterColumn('EXPLORE', [
                  'Design',
                  'Prototyping',
                  'Development',
                ]),
              ),
              // Cột 4: Resources
              Expanded(
                child: _buildFooterColumn('RESOURCES', [
                  'Blog',
                  'Best practices',
                  'Support',
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 TaskFlow Group 03 - Phenikaa University',
                style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 9, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
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
            fontSize: 10,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              item,
              style: TextStyle(color: Colors.grey[600], fontSize: 9.5),
            ),
          ),
        ),
      ],
    );
  }
}
