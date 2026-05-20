import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class ProjectTaskScreen extends StatefulWidget {
  final String projectName;
  const ProjectTaskScreen({Key? key, required this.projectName})
    : super(key: key);

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
  String _selectedFilter = 'Tất cả';
  String _selectedMemberFilter = 'Tất cả thành viên';

  final List<Map<String, dynamic>> mockTasks = [
    {
      'title': 'Viết Firebase Auth',
      'status': 'REVIEWING',
      'displayStatus': 'Review',
      'statusColor': Colors.blueAccent,
      'user': 'B',
      'isManagerOnly': false,
    },
    {
      'title': 'Thiết kế UI Login Screen',
      'status': 'DOING',
      'displayStatus': 'Doing',
      'statusColor': Colors.orangeAccent,
      'user': 'B',
      'isManagerOnly': false,
    },
    {
      'title': 'Project List Screen',
      'status': 'TODO',
      'displayStatus': 'Todo',
      'statusColor': Colors.redAccent,
      'user': 'B',
      'isManagerOnly': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.projectName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Đang tải danh sách...',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
