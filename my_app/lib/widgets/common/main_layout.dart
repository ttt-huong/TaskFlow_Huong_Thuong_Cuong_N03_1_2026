import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showImage;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.showImage = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF6366F1); // Modern Premium Indigo

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Logo & Brand Name on the Left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.task_alt, color: brandColor, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'TaskFlow',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Centered Page Title (mapped nicely for Trang Chủ)
                  Text(
                    title == 'TaskFlow' ? 'TRANG CHỦ' : title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                  ),
                  // Hamburger Menu on the Right
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.menu, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
