import 'package:flutter/material.dart';

// Lớp này định nghĩa Widget (Bạn đang thiếu phần này)
class BaiTapForm extends StatefulWidget {
  const BaiTapForm({super.key});

  @override
  State<BaiTapForm> createState() => _BaiTapFormState();
}

// Lớp này quản lý trạng thái (State)
class _BaiTapFormState extends State<BaiTapForm> {
  // a) Get Value: Khởi tạo giá trị mặc định
  String selectedPriority = 'Trung bình';
  final List<String> priorities = ['Thấp', 'Trung bình', 'Cao'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bài Tập Form - Project")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn mức độ ưu tiên dự án:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // b) Code chính của DropdownButton
            DropdownButton<String>(
              value: selectedPriority,
              isExpanded: true,
              onChanged: (String? newValue) {
                // Hàm xử lý lưu lại giá trị
                setState(() {
                  selectedPriority = newValue!;
                });
                print("Dữ liệu đã chọn: $selectedPriority");
              },
              items: priorities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(
              "Trạng thái hiện tại: $selectedPriority",
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
