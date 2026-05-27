import 'package:flutter/material.dart';

class MemberNotificationScreen extends StatelessWidget {
  const MemberNotificationScreen({super.key});

  Widget buildNotification(
    IconData icon,
    String title,
    String subtitle,
    Color color,
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
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
          'Thông báo cá nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildNotification(
              Icons.task_alt,
              'Task mới',
              'Bạn vừa được giao task thiết kế màn hình Profile.',
              Colors.blue,
            ),
            buildNotification(
              Icons.access_time,
              'Sắp đến hạn',
              'Task Flutter UI còn 1 ngày để hoàn thành.',
              Colors.orange,
            ),
            buildNotification(
              Icons.check_circle,
              'Hoàn thành',
              'Bạn đã hoàn thành 2 task trong tuần này.',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}