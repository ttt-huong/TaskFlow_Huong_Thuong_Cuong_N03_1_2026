import 'package:flutter/material.dart';

class MemberTaskScreen extends StatelessWidget {
  const MemberTaskScreen({super.key});

  Widget buildTaskCard(
    String title,
    String status,
    Color color,
    double progress,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(status, style: TextStyle(color: color)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Task của tôi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTaskCard(
              'Thiết kế màn hình Profile',
              'Đang làm',
              Colors.orange,
              0.6,
            ),
            buildTaskCard(
              'Hoàn thiện giao diện thống kê',
              'Hoàn thành',
              Colors.green,
              1.0,
            ),
            buildTaskCard(
              'Kiểm tra lỗi giao diện',
              'Chưa làm',
              Colors.red,
              0.2,
            ),
          ],
        ),
      ),
    );
  }
}