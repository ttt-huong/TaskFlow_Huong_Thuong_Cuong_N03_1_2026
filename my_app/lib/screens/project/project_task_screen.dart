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
    final provider = Provider.of<AppProvider>(context);
    bool isManager = false;
    try {
      isManager = (provider as dynamic).isManager ?? false;
    } catch (_) {}

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
        actions: [
          if (isManager)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((
                  tab,
                ) {
                  final isSelected = _selectedFilter == tab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: mockTasks.length,
                itemBuilder: (context, index) {
                  final task = mockTasks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161926),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      task['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
