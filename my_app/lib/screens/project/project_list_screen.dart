import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'project_task_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isManager = provider.isManager;

    final List<Map<String, dynamic>> projects = [
      {
        'title': 'App Flutter',
        'subtitle': 'Quản lý công việc nhóm',
        'todo': 2,
        'doing': 3,
        'done': 4,
        'progress': 0.65,
        'percent': '65%',
        'members': 3,
        'color': const Color(0xFF8B5CF6),
        'glowColor': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Báo cáo môn học',
        'subtitle': 'Tài liệu + slide thuyết trình',
        'todo': 4,
        'doing': 1,
        'done': 1,
        'progress': 0.30,
        'percent': '30%',
        'members': 2,
        'color': const Color(0xFF3B82F6),
        'glowColor': const Color(0xFF3B82F6),
      },
      {
        'title': 'UI Design Sprint',
        'subtitle': 'Prototype giao diện',
        'todo': 0,
        'doing': 1,
        'done': 9,
        'progress': 0.90,
        'percent': '90%',
        'members': 4,
        'color': const Color(0xFF10B981),
        'glowColor': const Color(0xFF10B981),
      },
    ];

    final int visibleCount = isManager ? projects.length : 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dự án',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$visibleCount projects',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isManager
                              ? const Color(0xFF8B5CF6).withOpacity(0.15)
                              : Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isManager
                                ? const Color(0xFF8B5CF6).withOpacity(0.4)
                                : Colors.blueAccent.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isManager
                                  ? Icons.shield_rounded
                                  : Icons.person_rounded,
                              size: 14,
                              color: isManager
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.blueAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isManager ? 'Manager' : 'Member',
                              style: TextStyle(
                                color: isManager
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.blueAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Greeting ──
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15),
                      children: [
                        const TextSpan(
                          text: 'Xin chào, ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextSpan(
                          text: isManager ? 'Nguyen Van A' : 'Tran Thi B',
                          style: TextStyle(
                            color: isManager
                                ? const Color(0xFF8B5CF6)
                                : Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: isManager ? ' 👑' : ' 👤'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Project Cards ──
                  Expanded(
                    child: ListView.builder(
                      itemCount: visibleCount,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return _ProjectCard(
                          project: project,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectTaskScreen(
                                  projectName: project['title'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── FAB tạo project (chỉ Manager) ──
            if (isManager)
              Positioned(
                bottom: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    // TODO: mở dialog tạo project
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng tạo dự án mới'),
                        backgroundColor: Color(0xFF8B5CF6),
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// Project Card Widget
// ════════════════════════════════════════
class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color accentColor = project['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161926),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ── Gradient accent glow góc trên phải ──
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.10),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          project['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      project['subtitle'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 16),

                    // Stat dots
                    Row(
                      children: [
                        _buildStatDot(
                          Colors.redAccent,
                          '${project['todo']} todo',
                        ),
                        const SizedBox(width: 12),
                        _buildStatDot(
                          Colors.orangeAccent,
                          '${project['doing']} doing',
                        ),
                        const SizedBox(width: 12),
                        _buildStatDot(
                          Colors.greenAccent,
                          '${project['done']} done',
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Số thành viên
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${project['members']} thành viên',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: project['progress'],
                              backgroundColor: const Color(0xFF1E2235),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          project['percent'],
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
