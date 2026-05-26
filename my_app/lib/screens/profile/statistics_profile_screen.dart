import 'package:flutter/material.dart';

class StatisticsProfileScreen extends StatelessWidget {
  final String role;

  const StatisticsProfileScreen({super.key, required this.role});

  Widget buildStatCard(
    String number,
    String title,
    Color color,
  ) {
    return Expanded(
      child: Container(
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

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              number,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget managerView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ===== BADGE =====
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(30),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [

              Icon(
                Icons.workspace_premium,
                color: Colors.deepPurple,
              ),

              SizedBox(width: 10),

              Text(
                "Manager - thống kê đầy đủ",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ===== TITLE =====
        const Text(
          "Thống kê",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // ===== CARD 1 =====
        Row(
          children: [

            Expanded(
              child: _buildDashboardCard(
                "9",
                "Tổng task",
                Colors.black,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _buildDashboardCard(
                "4",
                "Hoàn thành",
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ===== CARD 2 =====
        Row(
          children: [

            Expanded(
              child: _buildDashboardCard(
                "3",
                "Đang làm",
                Colors.orange,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _buildDashboardCard(
                "1",
                "Quá hạn",
                Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // ===== PROGRESS =====
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: const [

            Text(
              "Tiến độ tổng thể",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "44%",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        LinearProgressIndicator(
          value: 0.44,
          minHeight: 10,

          borderRadius:
              BorderRadius.circular(20),

          backgroundColor:
              Colors.grey.shade300,

          valueColor:
              const AlwaysStoppedAnimation(
            Colors.deepPurple,
          ),
        ),

        const SizedBox(height: 30),

        // ===== TEAM =====
        Container(
          padding: const EdgeInsets.all(20),

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

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                "HIỆU SUẤT THÀNH VIÊN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              buildMemberProgress(
                "Văn A",
                0.7,
                "2/3",
                Colors.deepPurple,
              ),

              buildMemberProgress(
                "Thị B",
                0.5,
                "2/5",
                Colors.orange,
              ),

              buildMemberProgress(
                "Văn C",
                0.3,
                "1/4",
                Colors.lightBlue,
              ),

              buildMemberProgress(
                "Thị D",
                0.0,
                "0/2",
                Colors.grey,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ===== NOTE =====
        Container(
          padding: const EdgeInsets.all(18),

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

          child: Column(
            children: const [

              Text(
                "Lưu ý số liệu, thanh tiến độ gradient,\nprogress bar theo từng thành viên.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Chỉ Manager truy cập được.",
                style: TextStyle(
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
Widget _buildDashboardCard(
  String number,
  String title,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(20),

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

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          number,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}
Widget memberView() {
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
          "Không có quyền",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),

          child: Text(
            "Chỉ Manager mới xem được thống kê toàn Project và hiệu suất thành viên.",
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(30),
          ),

          child: const Text(
            "403 - Forbidden",
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

  Widget buildMemberProgress(
    String name,
    double value,
    String task,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [

          SizedBox(
            width: 50,
            child: Text(name),
          ),

          Expanded(
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,

              borderRadius: BorderRadius.circular(20),

              backgroundColor: Colors.grey.shade300,

              valueColor:
                  AlwaysStoppedAnimation(color),
            ),
          ),

          const SizedBox(width: 10),

          Text(task),
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

        centerTitle: true,

        title: const Text(
          "Thống kê",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

     body: role == "manager"
    ? managerView()
    : memberView(),
    );
  }
}