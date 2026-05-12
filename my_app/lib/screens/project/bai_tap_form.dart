import 'package:flutter/material.dart';

class BaiTapFormScreen extends StatefulWidget {
  const BaiTapFormScreen({super.key});

  @override
  State<BaiTapFormScreen> createState() => _BaiTapFormScreenState();
}

class _BaiTapFormScreenState extends State<BaiTapFormScreen> {
  String _duLieuNhap = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bài Tập TextFieldForm")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nhập nội dung dự án...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _duLieuNhap = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Text(
              "Dữ liệu thu được: $_duLieuNhap",
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
