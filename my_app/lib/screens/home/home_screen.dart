import 'package:flutter/material.dart';
import '../../widgets/common/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DỮ LIỆU MẪU (Sửa ở đây để thay đổi nội dung) ---
    const String studentName = "Trần Thị Thu Hường";
    const String featuredTask = "Thiết kế giao diện App TaskFlow";
    const String deadline = "15/05";

    // Màu nhấn Tím Vivid sang trọng
    const Color accentColor = Color(0xFF8B5CF6);

    return MainLayout(
      title: 'TRANG CHỦ',
      showImage: true,
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SEGMENT CONTROL (Tổng quan / Nhiệm vụ)
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tổng quan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Nhiệm vụ của tôi',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. LỜI CHÀO
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(text: 'Xin chào, '),
                    TextSpan(
                      text: studentName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 3. THẺ CÔNG VIỆC NỔI BẬT (FEATURED CARD - Viền tím 1.5px)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha((0.08 * 255).round()),
                  border: Border.all(color: accentColor, width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TASK ĐANG THỰC HIỆN",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      featuredTask,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: Colors.red,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Còn 1 ngày · Hạn chót: $deadline',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Nộp bài →',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. STATS
              Row(
                children: [
                  _buildStatBox('TỔNG', '12', Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatBox('ĐANG LÀM', '05', Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatBox('HOÀN THÀNH', '07', Colors.green),
                ],
              ),

              const SizedBox(height: 30),

              // 5. LIST SẮP ĐẾN HẠN
              const Text(
                "SẮP ĐẾN HẠN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 15),

              _buildTaskItem('Viết báo cáo giữa kỳ', '08/05', accentColor),
              _buildTaskItem('Họp nhóm 03 Phenikaa', '10/05', accentColor),
              _buildTaskItem('Kiểm thử chức năng', '12/05', accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).round())),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String deadline, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).round()),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    '● Todo',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Deadline
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 12,
                color: Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                deadline,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
