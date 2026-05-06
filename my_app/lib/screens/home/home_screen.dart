import 'package:flutter/material.dart';
import '../../widgets/common/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    const String studentName = "Trần Thị Thu Hường";
    const String featuredTask = "Thiết kế giao diện App TaskFlow";
    const String deadline = "15/05";
    const Color accentColor = Color(0xFF8B5CF6);

    return MainLayout(
      title: 'Trang chủ',
      showImage: true,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TAB SELECTOR
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabItem(0, 'Tổng quan', accentColor),
                    _buildTabItem(1, 'Nhiệm vụ', accentColor),
                  ],
                ),
              ),

              // 2. TAB CONTENT
              IndexedStack(
                index: _activeTab,
                children: [
                  _buildOverviewTab(studentName, featuredTask, deadline, accentColor, key: const ValueKey('overview_tab')),
                  _buildMyTasksTab(accentColor, key: const ValueKey('tasks_tab')),
                ],
              ),

              const SizedBox(height: 80),
              _buildModernFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color accent) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(String name, String task, String dl, Color accent, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dùng RichText chuẩn để tránh lỗi render trên Web
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15, fontFamily: 'Roboto'),
            children: [
              const TextSpan(text: 'Xin chào, '),
              TextSpan(text: name, style: TextStyle(fontWeight: FontWeight.bold, color: accent)),
              const TextSpan(text: ' 👋'),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("TASK ĐANG THỰC HIỆN", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: accent, letterSpacing: 1)),
              const SizedBox(height: 12),
              Text(task, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text('Còn 1 ngày · Hạn chót: $dl', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Nộp bài ngay →', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text("THỐNG KÊ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatBox('TỔNG', '12', Colors.black),
            const SizedBox(width: 12),
            _buildStatBox('DOING', '03', accent),
            const SizedBox(width: 12),
            _buildStatBox('DONE', '09', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildMyTasksTab(Color accent, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildStatBox('TODO', '02', Colors.redAccent),
            const SizedBox(width: 8),
            _buildStatBox('DOING', '03', accent),
            const SizedBox(width: 8),
            _buildStatBox('DONE', '07', Colors.green),
          ],
        ),
        const SizedBox(height: 30),
        const Text("DANH SÁCH NHIỆM VỤ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _buildTaskItemDropdown('Thiết kế UI Login', '30/04', accent, 'Doing'),
        _buildTaskItemDropdown('Project List Screen', 'Chờ duyệt', Colors.blue, 'Reviewing'),
        _buildTaskItemDone('Tạo mock data', 'Done'),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItemDropdown(String title, String subtitle, Color color, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItemDone(String title, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough))),
          Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildModernFooter() {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.task_alt, size: 28, color: Colors.black),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Icon(Icons.close, size: 18, color: Colors.black54),
                      SizedBox(width: 12),
                      Icon(Icons.camera_alt_outlined, size: 18, color: Colors.black54),
                      SizedBox(width: 12),
                      Icon(Icons.play_circle_outline, size: 18, color: Colors.black54),
                      SizedBox(width: 12),
                      Icon(Icons.business_center_outlined, size: 18, color: Colors.black54),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _buildFooterLinkColumn('Use cases', ['UI design', 'UX design', 'Wireframing'])),
            Expanded(child: _buildFooterLinkColumn('Explore', ['Design', 'Prototyping', 'Systems'])),
            Expanded(child: _buildFooterLinkColumn('Resources', ['Blog', 'Best practices', 'Support'])),
          ],
        ),
        const SizedBox(height: 50),
        Text('© 2026 TaskFlow Group 03 — Phenikaa University', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFooterLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(link, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            )),
      ],
    );
  }
}
