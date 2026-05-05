import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // 6. main.dart (STRICT) - Chỉ khởi động app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
