import 'package:flutter/material.dart';

/// Hệ thống màu sắc chính thức của TaskFlow.
/// Bao gồm: màu nền, màu trạng thái Task, màu đồng bộ (Sync).
class AppColors {
  // ── Màu nền chủ đạo (Material Design 3 Light Theme) ──
  static const Color primary = Color(0xFF2196F3);       // Blue 600 - AppBar, Button
  static const Color secondary = Color(0xFF03A9F4);     // Light Blue 500 - Accents
  static const Color background = Color(0xFFF5F5F5);    // Grey 100 - Scaffold Background
  static const Color surface = Color(0xFFFFFFFF);       // White - Card, Dialog
  static const Color error = Color(0xFFD32F2F);         // Red 700 - Error States

  // ── Màu trạng thái Task (Status Colors) ──
  static const Color taskTodo = Color(0xFFE74C3C);       // Đỏ - Chưa bắt đầu
  static const Color taskDoing = Color(0xFFF39C12);      // Cam - Đang làm
  static const Color taskReviewing = Color(0xFF3498DB);  // Xanh dương - Chờ duyệt
  static const Color taskDone = Color(0xFF27AE60);       // Xanh lá - Hoàn thành
  static const Color taskArchived = Color(0xFF7F8C8D);   // Xám - Lưu trữ
  static const Color taskCancelled = Color(0xFF2C3E50);  // Đen/xám tối - Hủy
  static const Color taskOverdue = Color(0xFFC0392B);    // Đỏ đậm - Quá hạn

  // ── Màu trạng thái đồng bộ (Dual Storage Indicator) ──
  static const Color synced = Color(0xFF27AE60);         // Xanh lá - Đã sync
  static const Color pending = Color(0xFFF39C12);        // Vàng - Chờ sync
  static const Color errorSync = Color(0xFFE74C3C);      // Đỏ - Lỗi sync

  /// Lấy màu tương ứng theo trạng thái Task
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':      return taskTodo;
      case 'doing':     return taskDoing;
      case 'reviewing': return taskReviewing;
      case 'done':      return taskDone;
      case 'archived':  return taskArchived;
      case 'cancelled': return taskCancelled;
      default:          return Colors.grey;
    }
  }

  /// Lấy tên hiển thị tiếng Việt theo trạng thái Task
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'todo':      return 'Chưa bắt đầu';
      case 'doing':     return 'Đang làm';
      case 'reviewing': return 'Chờ duyệt';
      case 'done':      return 'Hoàn thành';
      case 'archived':  return 'Lưu trữ';
      case 'cancelled': return 'Đã hủy';
      default:          return status;
    }
  }

  /// Lấy icon theo trạng thái Task
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'todo':      return Icons.radio_button_unchecked;
      case 'doing':     return Icons.play_circle_outline;
      case 'reviewing': return Icons.rate_review_outlined;
      case 'done':      return Icons.check_circle;
      case 'archived':  return Icons.archive_outlined;
      case 'cancelled': return Icons.cancel_outlined;
      default:          return Icons.help_outline;
    }
  }
}

/// Cấu hình Theme chính cho toàn app.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
