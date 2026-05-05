import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'home/home_screen.dart';
import 'project/project_list_screen.dart';
import 'user/user_list_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Buổi 2: Tạm thời hardcode role để test giao diện
  // Bạn có thể đổi sang 'member' để thấy sự khác biệt
  final String _role = 'member';

  // Danh sách các màn hình tương ứng với các Tab
  List<Widget> _getPages() {
    if (_role == 'manager') {
      return [
        const HomeScreen(),
        const ProjectListScreen(),
        const UserListScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const HomeScreen(),
        const ProjectListScreen(),
        const ProfileScreen(),
      ];
    }
  }

  // Danh sách các item của BottomNavigationBar
  List<BottomNavigationBarItem> _getNavItems() {
    if (_role == 'manager') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Projects',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Team'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Projects',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed, // Cần thiết khi có > 3 items
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _getNavItems(),
      ),
    );
  }
}
