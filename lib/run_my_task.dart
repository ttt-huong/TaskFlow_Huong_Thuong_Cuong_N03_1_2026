import 'package:flutter/material.dart';

class BaiTapForm extends StatefulWidget {
  const BaiTapForm({super.key});

  @override
  State<BaiTapForm> createState() => _BaiTapFormState();
}

class _BaiTapFormState extends State<BaiTapForm> {
  // --- DỮ LIỆU LƯU TRỮ (Get Value) ---
  String projectName = ""; // Lưu dữ liệu từ TextField
  String selectedPriority = 'Trung bình'; // Lưu dữ liệu từ Dropdown
  final List<String> priorities = ['Thấp', 'Trung bình', 'Cao'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài Tập 2 - TaskFlow"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === YÊU CẦU 1: TextFieldForm ===
            const Text(
              "1. Tên dự án (TextField):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập tên dự án tại đây...',
              ),
              // Hàm xử lý lưu lại giá trị mỗi khi người dùng gõ
              onChanged: (value) {
                setState(() {
                  projectName = value;
                });
                // In ra console để làm minh chứng Get Value
                print("Đang gõ tên dự án: $projectName");
              },
            ),

            const SizedBox(height: 30),

            // === YÊU CẦU 2: Đối tượng lựa chọn (DropdownButton) ===
            const Text(
              "2. Mức độ ưu tiên (Dropdown):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: priorities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              // Hàm xử lý khi người dùng chọn một giá trị mới
              onChanged: (String? newValue) {
                setState(() {
                  selectedPriority = newValue!;
                });
                print("Đã chọn mức độ ưu tiên: $selectedPriority");
              },
            ),

            const SizedBox(height: 40),

            // Khu vực hiển thị kết quả để bạn dễ chụp ảnh UI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "Dữ liệu tên dự án: $projectName",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Dữ liệu ưu tiên: $selectedPriority",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
