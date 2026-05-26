import 'package:flutter/material.dart';

class ManagerNotificationScreen
    extends StatelessWidget {
  const ManagerNotificationScreen({super.key});

  Widget buildNotification(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
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
        elevation: 0,

        title: const Text(
          "Thông báo quản lý",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            buildNotification(
              Icons.warning,
              "Task quá hạn",
              "Có 2 task chưa hoàn thành.",
              Colors.red,
            ),

            buildNotification(
              Icons.person_add,
              "Thành viên mới",
              "Nguyễn Văn A đã tham gia team.",
              Colors.blue,
            ),

            buildNotification(
              Icons.check_circle,
              "Task hoàn thành",
              "UI Mobile đã được hoàn tất.",
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}