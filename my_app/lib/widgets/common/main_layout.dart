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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(showImage ? 140 : 70),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.task_alt, color: Colors.black, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'TaskFlow',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.menu, color: Colors.black87),
                    ],
                  ),
                  if (showImage) ...[
                    const SizedBox(height: 15),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -1,
                      ),
                    ),
                  ]
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
