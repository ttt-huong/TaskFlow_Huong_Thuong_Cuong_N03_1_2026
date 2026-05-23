import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'project_list_screen.dart';
import 'user_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _managerPages = [
    const HomeScreen(),
    const ProjectListScreen(),
    const UserListScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _memberPages = [
    const HomeScreen(),
    const ProjectListScreen(),
    const ProfileScreen(),
  ];

  List<BottomNavigationBarItem> _getNavItems(String role) {
    if (role == 'manager') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Team'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.currentUser?.role ?? 'member';
    final pages = role == 'manager' ? _managerPages : _memberPages;

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _getNavItems(role),
        ),
      ),
    );
  }
}
