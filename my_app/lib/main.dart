import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import đúng đường dẫn màn hình danh sách dự án của nhóm bạn
import 'screens/project/project_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainNavigationScreen(),
      ),
    ),
  );
}

// PROVIDER QUẢN LÝ VAI TRÒ GIẢ LẬP ĐỂ TEST PHÂN QUYỀN
class AppProvider extends ChangeNotifier {
  String _currentRole = 'manager';

  String get currentRole => _currentRole;
  bool get isManager => _currentRole == 'manager';

  void toggleRole() {
    _currentRole = _currentRole == 'manager' ? 'member' : 'manager';
    notifyListeners();
  }
}

// MÀN HÌNH ĐIỀU HƯỚNG CHÍNH (BOTTOM NAV BAR)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1; // Mặc định hiển thị tab Projects (vị trí số 1)

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Gom toàn bộ các màn hình về một mối, bọc Center an toàn cho các tab chưa làm
    final List<Widget> screens = [
      const Center(
        child: Text(
          'Màn hình Tổng quan (Home)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      const ProjectListScreen(),
      const Center(
        child: Text(
          'Màn hình Quản lý Thành viên (Team)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      const Center(
        child: Text(
          'Màn hình Cá nhân (Profile)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(child: screens[_selectedIndex]),

      // Nút đổi vai trò nổi để test phân quyền nhanh
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => provider.toggleRole(),
        label: Text(
          provider.isManager ? "Vai trò: Manager 👑" : "Vai trò: Member 👤",
        ),
        icon: const Icon(Icons.swap_horizontal_circle, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF131623),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9061F9),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          if (provider.isManager)
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Team',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
