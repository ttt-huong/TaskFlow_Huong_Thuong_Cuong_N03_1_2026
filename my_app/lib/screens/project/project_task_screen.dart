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

  // Màu avatar theo user
  Color _avatarColor(String user) {
    switch (user) {
      case 'A':
        return const Color(0xFF8B5CF6);
      case 'B':
        return const Color(0xFF3B82F6);
      case 'C':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  final List<Map<String, dynamic>> mockTasks = [
    {
      'title': 'Viết Firebase Auth',
      'status': 'REVIEWING',
      'displayStatus': 'Review',
      'statusColor': Colors.blueAccent,
      'user': 'B',
      'deadline': '30/04',
      'isOverdue': true,
      'isManagerOnly': false,
    },
    {
      'title': 'Thiết kế UI Login Screen',
      'status': 'DOING',
      'displayStatus': 'Doing',
      'statusColor': Colors.orangeAccent,
      'user': 'B',
      'deadline': '05/05',
      'isOverdue': false,
      'isManagerOnly': false,
    },
    {
      'title': 'Project List Screen',
      'status': 'TODO',
      'displayStatus': 'Todo',
      'statusColor': Colors.redAccent,
      'user': 'B',
      'deadline': null,
      'isOverdue': false,
      'isManagerOnly': false,
    },
    {
      'title': 'Thiết kế UI Login',
      'status': 'DOING',
      'displayStatus': 'Doing',
      'statusColor': Colors.orangeAccent,
      'user': 'C',
      'deadline': '28/04',
      'isOverdue': true,
      'isManagerOnly': true,
    },
    {
      'title': 'Viết báo cáo chương 2',
      'status': 'TODO',
      'displayStatus': 'Todo',
      'statusColor': Colors.redAccent,
      'user': 'A',
      'deadline': '22/04',
      'isOverdue': true,
      'isManagerOnly': true,
    },
    {
      'title': 'Tạo mock data',
      'status': 'DONE',
      'displayStatus': 'Done',
      'statusColor': Colors.green,
      'user': 'B',
      'deadline': '11/04',
      'isOverdue': false,
      'isManagerOnly': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final bool isManager = provider.isManager;

    // Lọc theo vai trò
    List<Map<String, dynamic>> roleFiltered = isManager
        ? mockTasks
        : mockTasks.where((t) => t['isManagerOnly'] == false).toList();

    // Lọc theo thành viên (chỉ Manager)
    if (isManager && _selectedMemberFilter != 'Tất cả thành viên') {
      roleFiltered = roleFiltered
          .where((t) => 'Thành viên ${t['user']}' == _selectedMemberFilter)
          .toList();
    }

    // Lọc theo tab status
    List<Map<String, dynamic>> finalTasks = _selectedFilter == 'Tất cả'
        ? roleFiltered
        : roleFiltered
              .where((t) => t['displayStatus'] == _selectedFilter)
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              isManager
                  ? '${finalTasks.length} tasks hiển thị'
                  : '${finalTasks.length} tasks của bạn',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng thêm task mới'),
                      backgroundColor: Color(0xFF8B5CF6),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Filter tabs ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((
                  tab,
                ) {
                  final isSelected = _selectedFilter == tab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
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
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ── Member filter (Manager only) ──
            if (isManager)
              _MemberDropdown(
                selected: _selectedMemberFilter,
                onChanged: (val) => setState(() => _selectedMemberFilter = val),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline, color: Colors.grey, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Chỉ hiển thị task được gán cho bạn',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Task List ──
            Expanded(
              child: finalTasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            color: Colors.grey,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Không có task nào phù hợp',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: finalTasks.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        final task = finalTasks[index];
                        final bool isReviewing = task['status'] == 'REVIEWING';
                        final bool isDone = task['status'] == 'DONE';
                        final Color statusColor = task['statusColor'] as Color;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161926),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  // Color bar kisi
                                  Container(
                                    width: 4,
                                    color: isDone
                                        ? Colors.grey.withOpacity(0.3)
                                        : statusColor,
                                  ),

                                  // Content
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title + avatar
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  task['title'] as String,
                                                  style: TextStyle(
                                                    color: isDone
                                                        ? Colors.grey
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    decoration: isDone
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Avatar
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor: _avatarColor(
                                                  task['user'] as String,
                                                ).withOpacity(0.2),
                                                child: Text(
                                                  task['user'] as String,
                                                  style: TextStyle(
                                                    color: _avatarColor(
                                                      task['user'] as String,
                                                    ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          // Status chip + deadline + actions
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              // Status chip
                                              _StatusChip(
                                                label: task['status'] as String,
                                                color: statusColor,
                                                isDone: isDone,
                                              ),

                                              // Deadline
                                              if (task['deadline'] != null)
                                                _DeadlineBadge(
                                                  date:
                                                      task['deadline']
                                                          as String,
                                                  isOverdue:
                                                      task['isOverdue'] as bool,
                                                ),

                                              // Approve/Reject buttons (Manager + Reviewing)
                                              if (isManager && isReviewing) ...[
                                                _ActionButton(
                                                  label: 'Từ chối',
                                                  color: Colors.orangeAccent,
                                                  onTap: () {
                                                    setState(() {
                                                      task['status'] = 'DOING';
                                                      task['displayStatus'] =
                                                          'Doing';
                                                      task['statusColor'] =
                                                          Colors.orangeAccent;
                                                    });
                                                  },
                                                ),
                                                _ActionButton(
                                                  label: 'Duyệt',
                                                  color: Colors.greenAccent,
                                                  onTap: () {
                                                    setState(() {
                                                      task['status'] = 'DONE';
                                                      task['displayStatus'] =
                                                          'Done';
                                                      task['statusColor'] =
                                                          Colors.green;
                                                      task['isOverdue'] = false;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

// ════════════════════════════════════════
// Member Dropdown (dark theme)
// ════════════════════════════════════════
class _MemberDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MemberDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final members = [
      'Tất cả thành viên',
      'Thành viên A',
      'Thành viên B',
      'Thành viên C',
    ];

    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: const Color(0xFF1E2235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => members
          .map(
            (m) => PopupMenuItem(
              value: m,
              child: Text(
                m,
                style: TextStyle(
                  color: m == selected ? const Color(0xFF8B5CF6) : Colors.white,
                  fontWeight: m == selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              color: Color(0xFF8B5CF6),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              selected,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// Status Chip
// ════════════════════════════════════════
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDone;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDone ? Colors.grey : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: effectiveColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// Deadline Badge
// ════════════════════════════════════════
class _DeadlineBadge extends StatelessWidget {
  final String date;
  final bool isOverdue;

  const _DeadlineBadge({required this.date, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today,
          size: 12,
          color: isOverdue ? Colors.redAccent : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: TextStyle(
            color: isOverdue ? Colors.redAccent : Colors.grey,
            fontSize: 12,
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════
// Action Button (Duyệt / Từ chối)
// ════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
