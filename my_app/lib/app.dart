import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
      ),
      // Start at login so the app requires authentication on launch
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
