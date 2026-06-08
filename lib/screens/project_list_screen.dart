import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../models/project_model.dart';
import 'project_task_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // name | progress | tasks

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<ProjectProvider>(context, listen: false)
            .loadProjects(auth.currentUser!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Color _accentColor(int index) {
    const colors = [
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
    ];
    return colors[index % colors.length];
  }

  List<ProjectModel> _sortedProjects(List<ProjectModel> projects) {
    final list = List<ProjectModel>.from(projects);
    switch (_sortBy) {
      case 'progress':
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'tasks':
        list.sort((a, b) => (b.todoCount + b.doingCount + b.doneCount)
            .compareTo(a.todoCount + a.doingCount + a.doneCount));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  // Health score tính theo: % done, overdue, review
  int _healthScore(ProjectModel p) {
    final total = p.todoCount + p.doingCount + p.doneCount;
    if (total == 0) return 100;
    final doneRate = (p.doneCount / total) * 70;
    final reviewPenalty = (p.doingCount / total) * 10;
    return (doneRate + 30 - reviewPenalty).clamp(0, 100).round();
  }

  Color _healthColor(int score) {
    if (score >= 85) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _healthLabel(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 60) return 'Good';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isManager = authProvider.currentUser?.isManager ?? false;
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final projects = _sortedProjects(projectProvider.filteredProjects);

    // Notification counts
    final overdueCount = taskProvider.overdueCount;
    final reviewCount = taskProvider.reviewingCount;
    final notifCount = overdueCount + reviewCount;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── SliverAppBar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
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
                                  '${projects.length} projects',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Notification badge
                                if (notifCount > 0)
                                  Stack(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E2235),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                            Icons.notifications_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$notifCount',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                _RoleBadge(isManager: isManager),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Greeting
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 15),
                            children: [
                              const TextSpan(
                                  text: 'Xin chào, ',
                                  style: TextStyle(color: Colors.grey)),
                              TextSpan(
                                text: authProvider.currentUser?.name ??
                                    (isManager ? 'Quản lý' : 'Thành viên'),
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

                        const SizedBox(height: 20),

                        // Deadline Alert
                        if (!projectProvider.isLoading)
                          _DeadlineAlert(taskProvider: taskProvider),

                        const SizedBox(height: 16),

                        // Dashboard Summary
                        if (!projectProvider.isLoading)
                          _DashboardSummary(provider: projectProvider),

                        const SizedBox(height: 20),

                        // Search
                        _SearchBar(
                          controller: _searchController,
                          onChanged: (q) => projectProvider.setSearchQuery(q),
                        ),

                        const SizedBox(height: 12),

                        // Filter + Sort row
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      ['All', 'Active', 'Completed'].map((s) {
                                    final isSelected =
                                        projectProvider.filterStatus == s;
                                    return GestureDetector(
                                      onTap: () =>
                                          projectProvider.setFilterStatus(s),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF8B5CF6)
                                              : const Color(0xFF1E2235),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF8B5CF6)
                                                            .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          s,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            // Sort button
                            PopupMenuButton<String>(
                              onSelected: (val) =>
                                  setState(() => _sortBy = val),
                              color: const Color(0xFF1E2235),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2235),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.sort_rounded,
                                        color: Colors.grey, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _sortBy == 'name'
                                          ? 'Tên'
                                          : _sortBy == 'progress'
                                              ? 'Tiến độ'
                                              : 'Tasks',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              itemBuilder: (_) => [
                                _sortMenuItem('name', 'Tên A-Z',
                                    Icons.sort_by_alpha_rounded),
                                _sortMenuItem('progress', 'Tiến độ',
                                    Icons.trending_up_rounded),
                                _sortMenuItem(
                                    'tasks', 'Số task', Icons.task_rounded),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ── Project List ──
                projectProvider.isLoading
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF8B5CF6)),
                        ),
                      )
                    : projects.isEmpty
                        ? SliverFillRemaining(
                            child: _EmptyState(
                              hasSearch: _searchController.text.isNotEmpty,
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final project = projects[index];
                                  final accent = _accentColor(index);
                                  final score = _healthScore(project);

                                  return FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: _animController,
                                      curve: Interval(
                                        (index * 0.1).clamp(0.0, 0.9),
                                        1.0,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: _animController,
                                        curve: Interval(
                                          (index * 0.1).clamp(0.0, 0.9),
                                          1.0,
                                          curve: Curves.easeOut,
                                        ),
                                      )),
                                      child: _ProjectCard(
                                        project: project,
                                        accentColor: accent,
                                        isManager: isManager,
                                        healthScore: score,
                                        healthColor: _healthColor(score),
                                        healthLabel: _healthLabel(score),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProjectTaskScreen(
                                                projectId: project.id,
                                                projectName: project.name,
                                              ),
                                            ),
                                          );
                                        },
                                        onEdit: isManager
                                            ? () => _showEditDialog(context,
                                                project, projectProvider)
                                            : null,
                                        onDelete: isManager
                                            ? () => _showDeleteConfirm(context,
                                                project, projectProvider)
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                childCount: projects.length,
                              ),
                            ),
                          ),
              ],
            ),

            // ── FAB ──
            if (isManager)
              Positioned(
                bottom: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => _showCreateDialog(context, projectProvider),
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

  PopupMenuItem<String> _sortMenuItem(
      String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: _sortBy == value
                      ? const Color(0xFF8B5CF6)
                      : Colors.white)),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, ProjectProvider provider) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _ProjectDialog(
        title: 'Tạo dự án mới',
        nameController: nameCtrl,
        descController: descCtrl,
        onConfirm: () async {
          final name = nameCtrl.text.trim();
          final desc = descCtrl.text.trim();
          if (name.isNotEmpty) {
            await provider.createProject(name, desc, []);
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, ProjectModel project, ProjectProvider provider) {
    final nameCtrl = TextEditingController(text: project.name);
    final descCtrl = TextEditingController(text: project.description);
    showDialog(
      context: context,
      builder: (_) => _ProjectDialog(
        title: 'Chỉnh sửa dự án',
        nameController: nameCtrl,
        descController: descCtrl,
        onConfirm: () async {
          final name = nameCtrl.text.trim();
          final desc = descCtrl.text.trim();
          if (name.isNotEmpty) {
            project.name = name;
            project.description = desc;
            await provider.updateProject(project);
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, ProjectModel project, ProjectProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161926),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa dự án?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc muốn xóa "${project.name}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await provider.deleteProject(project.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Deadline Alert
// ════════════════════════════════════════
class _DeadlineAlert extends StatelessWidget {
  final TaskProvider taskProvider;
  const _DeadlineAlert({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final overdue = taskProvider.overdueCount;
    final tasks = taskProvider.tasks;
    final now = DateTime.now();
    final soon = tasks
        .where((t) =>
            !t.isOverdue() &&
            t.status != 'done' &&
            t.deadline.difference(now).inDays <= 3)
        .length;

    if (overdue == 0 && soon == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161926),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 16,
              children: [
                if (overdue > 0)
                  Text('🔴 Quá hạn: $overdue',
                      style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                if (soon > 0)
                  Text('🟡 Sắp đến hạn: $soon',
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Dashboard Summary
// ════════════════════════════════════════
class _DashboardSummary extends StatelessWidget {
  final ProjectProvider provider;
  const _DashboardSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161926),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng quan',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatItem(
                  label: 'Dự án',
                  value: '${provider.totalProjects}',
                  color: const Color(0xFF8B5CF6)),
              _StatItem(
                  label: 'Tổng Task',
                  value: '${provider.totalTasks}',
                  color: const Color(0xFF3B82F6)),
              _StatItem(
                  label: 'Hoàn thành',
                  value: '${provider.completedTasks}',
                  color: const Color(0xFF10B981)),
              _StatItem(
                  label: 'Tỉ lệ',
                  value: '${provider.overallCompletion.toStringAsFixed(0)}%',
                  color: const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Search Bar
// ════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm dự án...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search_rounded,
            color: Color(0xFF8B5CF6), size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF161926),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

// ════════════════════════════════════════
// Role Badge
// ════════════════════════════════════════
class _RoleBadge extends StatelessWidget {
  final bool isManager;
  const _RoleBadge({required this.isManager});

  @override
  Widget build(BuildContext context) {
    final color = isManager ? const Color(0xFF8B5CF6) : Colors.blueAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(isManager ? Icons.shield_rounded : Icons.person_rounded,
              size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            isManager ? 'Manager' : 'Member',
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Project Card
// ════════════════════════════════════════
class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final Color accentColor;
  final bool isManager;
  final int healthScore;
  final Color healthColor;
  final String healthLabel;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ProjectCard({
    required this.project,
    required this.accentColor,
    required this.isManager,
    required this.healthScore,
    required this.healthColor,
    required this.healthLabel,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final total = p.todoCount + p.doingCount + p.doneCount;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161926),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withOpacity(0.4)
                  : Colors.white.withOpacity(0.05),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Glow
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withOpacity(0.08),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                if (p.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    p.description,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.isManager) ...[
                            _IconAction(
                              icon: Icons.edit_rounded,
                              color: const Color(0xFF8B5CF6),
                              onTap: widget.onEdit ?? () {},
                            ),
                            const SizedBox(width: 6),
                            _IconAction(
                              icon: Icons.delete_rounded,
                              color: const Color(0xFFEF4444),
                              onTap: widget.onDelete ?? () {},
                            ),
                          ] else
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.folder_rounded,
                                  color: widget.accentColor, size: 18),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: p.progress,
                                    backgroundColor: const Color(0xFF1E2235),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.accentColor,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(p.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Task counts
                      Row(
                        children: [
                          _TaskCount(
                              label: 'Todo',
                              count: p.todoCount,
                              color: const Color(0xFFEF4444)),
                          _TaskCount(
                              label: 'Doing',
                              count: p.doingCount,
                              color: const Color(0xFFF59E0B)),
                          _TaskCount(
                              label: 'Done',
                              count: p.doneCount,
                              color: const Color(0xFF10B981)),
                          if (total > 0)
                            _TaskCount(
                                label: 'Total',
                                count: total,
                                color: Colors.grey),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Footer: members + health score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_outline,
                                  color: Colors.grey, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${p.memberIds.length} thành viên',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          // Health score
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.healthColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: widget.healthColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.favorite_rounded,
                                    color: widget.healthColor, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.healthScore} · ${widget.healthLabel}',
                                  style: TextStyle(
                                    color: widget.healthColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

class _TaskCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _TaskCount(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Empty State
// ════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.folder_off_rounded,
            color: Colors.grey.withOpacity(0.4),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Không tìm thấy dự án phù hợp' : 'Chưa có dự án nào',
            style: const TextStyle(
                color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Nhấn + để tạo dự án đầu tiên',
            style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// Project Dialog
// ════════════════════════════════════════
class _ProjectDialog extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController descController;
  final VoidCallback onConfirm;

  const _ProjectDialog({
    required this.title,
    required this.nameController,
    required this.descController,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161926),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DarkTextField(
              controller: nameController,
              label: 'Tên dự án',
              icon: Icons.folder_rounded),
          const SizedBox(height: 12),
          _DarkTextField(
              controller: descController,
              label: 'Mô tả',
              icon: Icons.notes_rounded),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onConfirm,
          child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  const _DarkTextField(
      {required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey, size: 18),
        filled: true,
        fillColor: const Color(0xFF1E2235),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
}
