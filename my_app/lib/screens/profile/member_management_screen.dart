import 'package:flutter/material.dart';

class MemberManagementScreen
    extends StatelessWidget {
  const MemberManagementScreen({super.key});

  Widget buildMember(
    String name,
    String role,
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
            backgroundColor: color,
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  role,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.more_vert),
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
          "Quản lý thành viên",
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

            buildMember(
              "Trần Thị B",
              "Manager",
              Colors.deepPurple,
            ),

            buildMember(
              "Nguyễn Văn A",
              "Developer",
              Colors.blue,
            ),

            buildMember(
              "Lê Văn C",
              "Designer",
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}