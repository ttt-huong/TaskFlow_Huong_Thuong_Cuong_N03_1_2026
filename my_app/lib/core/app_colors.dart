import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static final Color primaryDark = Colors.blue.shade900;
  static final Color primaryLight = Colors.blue.shade400;
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color error = Colors.red;
  static const Color grey = Colors.grey;

  // Màu trạng thái Task (Chuẩn hóa từ TaskFlow documentation)
  static const Color todo = Color(0xFFE74C3C);
  static const Color doing = Color(0xFFF39C12);
  static const Color done = Color(0xFF27AE60);
  
  static final List<Color> loginGradient = [
    Colors.blue.shade800,
    Colors.blue.shade400,
  ];

  static final List<Color> registerGradient = [
    Colors.blue.shade900,
    Colors.blue.shade500,
  ];
}
