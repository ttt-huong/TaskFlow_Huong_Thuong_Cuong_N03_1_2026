import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import đúng đường dẫn các file màn hình thực tế của bạn
import 'screens/home/home_screen.dart';
import 'screens/project/project_list_screen.dart';
import 'screens/user/user_list_screen.dart'; // Đã đổi theo class UserListScreen của bạn
import 'screens/profile/profile_screen.dart';

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

    // Danh sách 4 màn hình thực tế chạy theo 4 nút dưới thanh điều hướng
    final List<Widget> screens = [
      const HomeScreen(), // Index 0: Màn hình Tổng quan
      const ProjectListScreen(), // Index 1: Màn hình Dự án
      const UserListScreen(), // Index 2: Màn hình Quản lý thành viên (Khớp với class của bạn)
      const ProfileScreen(), // Index 3: Màn hình Cá nhân
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(child: screens[_selectedIndex]),

      // Nút nổi đổi vai trò để test phân quyền ẩn/hiện chức năng
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => provider.toggleRole(),
        label: Text(
          provider.isManager ? "Vai trò: Manager 👑" : "Vai trò: Member 👤",
        ),
        icon: const Icon(Icons.swap_horizontal_circle, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      // Thanh điều hướng cố định 4 nút tương ứng với 4 màn hình
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF131623),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9061F9),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Chuyển đổi vị trí Index khi bấm tab
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Team',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
