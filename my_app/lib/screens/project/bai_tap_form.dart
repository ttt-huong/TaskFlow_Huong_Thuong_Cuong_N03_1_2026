import 'package:flutter/material.dart';

// 1. Lớp StatefulWidget định nghĩa Widget cho bài tập
class BaiTapForm extends StatefulWidget {
  const BaiTapForm({super.key});

  @override
  State<BaiTapForm> createState() => _BaiTapFormState();
}

// 2. Lớp State quản lý dữ liệu và logic xử lý
class _BaiTapFormState extends State<BaiTapForm> {
  // a) Get Value: Biến lưu trữ giá trị được chọn từ người dùng
  String selectedPriority = 'Trung bình';

  // Danh sách các tùy chọn cho đối tượng (Dành cho phần Project)
  final List<String> priorities = ['Thấp', 'Trung bình', 'Cao'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài Tập 2 - Quản lý Project"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn mức độ ưu tiên cho dự án:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // b) Code chính: Đối tượng DropdownButton để lấy dữ liệu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPriority,
                  isExpanded: true,
                  icon: const Icon(Icons.priority_high, color: Colors.blue),
                  items: priorities.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),

                  // Hàm xử lý khi người dùng thay đổi lựa chọn (Lưu lại giá trị)
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedPriority =
                            newValue; // Cập nhật giá trị mới vào biến
                      });
                      // In ra console để kiểm tra dữ liệu đã lấy được
                      print("Dữ liệu người dùng đã chọn: $selectedPriority");
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Hiển thị kết quả để bạn dễ chụp ảnh minh họa cho bài tập
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Dữ liệu đã nhận: $selectedPriority",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
