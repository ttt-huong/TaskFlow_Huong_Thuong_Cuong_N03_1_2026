import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5B5FEF); // Updated primary per spec
  static const Color primaryDark = Color(0xFF4146C9);
  static const Color primaryLight = Color(0xFF818CF8);
  
  static const Color background = Color(0xFFF8F9FD); // Slightly warm off-white per spec
  static const Color white = Colors.white;
  static const Color error = Color(0xFFEF4444); // Rose/Red-500
  static const Color grey = Color(0xFF94A3B8); // Slate-400

  // Typography colors
  static const Color text = Color(0xFF1A1D26); // Dark but not pure black (spec)
  static const Color secondaryText = Color(0xFF7D8592); // Spec secondary

  // Màu trạng thái Task (Chuẩn hóa từ TaskFlow documentation)
  static const Color todo = Color(0xFFEF4444); // Red
  static const Color doing = Color(0xFFF59E0B); // Amber
  static const Color reviewing = Color(0xFF3B82F6); // Blue
  static const Color done = Color(0xFF10B981); // Emerald
  
  static const List<Color> loginGradient = [
    Color(0xFF5B5FEF),
    Color(0xFF6366F1),
  ];

  static const List<Color> registerGradient = [
    Color(0xFF4146C9),
    Color(0xFF5B5FEF),
  ];
}
