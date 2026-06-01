import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import 'project_task_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isManager = authProvider.currentUser?.isManager ?? false;
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.filteredProjects;

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + role badge
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
                            _RoleBadge(isManager: isManager),
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

                        // ── Dashboard Summary ──
                        if (!projectProvider.isLoading)
                          _DashboardSummary(provider: projectProvider),

                        const SizedBox(height: 20),

                        // ── Search ──
                        _SearchBar(
                          controller: _searchController,
                          onChanged: (q) => projectProvider.setSearchQuery(q),
                        ),

                        const SizedBox(height: 14),

                        // ── Filter Chips ──
                        _FilterChips(
                          selected: projectProvider.filterStatus,
                          onSelected: (s) => projectProvider.setFilterStatus(s),
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
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.folder_off_rounded,
                                      color: Colors.grey, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'Không tìm thấy dự án phù hợp'
                                        : 'Không có dự án nào',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final project = projects[index];
                                  final accent = _accentColor(index);
                                  final score = projectProvider
                                      .productivityScore(project);
                                  return _ProjectCard(
                                    project: project,
                                    accentColor: accent,
                                    isManager: isManager,
                                    productivityScore: score,
                                    productivityLabel: projectProvider
                                        .productivityLabel(score),
                                    productivityColor: projectProvider
                                        .productivityColor(score),
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
                                        ? () => _showEditProjectDialog(
                                            context, project, projectProvider)
                                        : null,
                                    onDelete: isManager
                                        ? () => _showDeleteConfirm(
                                            context, project, projectProvider)
                                        : null,
                                  );
                                },
                                childCount: projects.length,
                              ),
                            ),
                          ),
              ],
            ),

            // ── FAB (Manager only) ──
            if (isManager)
              Positioned(
                bottom: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () =>
                      _showCreateProjectDialog(context, projectProvider),
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

  void _showCreateProjectDialog(
      BuildContext context, ProjectProvider provider) {
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

  void _showEditProjectDialog(
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
          'Bạn có chắc muốn xóa "${project.name}"? Hành động này không thể hoàn tác.',
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
// Filter Chips
// ════════════════════════════════════════
class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['All', 'Active', 'Completed'].map((s) {
        final isSelected = selected == s;
        return GestureDetector(
          onTap: () => onSelected(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF1E2235),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]
                  : [],
            ),
            child: Text(
              s,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════
// Project Card
// ════════════════════════════════════════
class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final Color accentColor;
  final bool isManager;
  final int productivityScore;
  final String productivityLabel;
  final Color productivityColor;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ProjectCard({
    required this.project,
    required this.accentColor,
    required this.isManager,
    required this.productivityScore,
    required this.productivityLabel,
    required this.productivityColor,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              // Gradient glow
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
                    // Title + actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        if (isManager) ...[
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF8B5CF6).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: Color(0xFF8B5CF6), size: 15),
                            ),
                          ),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFEF4444).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: Color(0xFFEF4444), size: 15),
                            ),
                          ),
                        ] else
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.folder_rounded,
                                color: accentColor, size: 18),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(project.description,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),

                    const SizedBox(height: 14),

                    // Stat dots
                    Row(
                      children: [
                        _StatDot(
                            color: const Color(0xFFEF4444),
                            label: '${project.todoCount} todo'),
                        const SizedBox(width: 12),
                        _StatDot(
                            color: const Color(0xFFF59E0B),
                            label: '${project.doingCount} doing'),
                        const SizedBox(width: 12),
                        _StatDot(
                            color: const Color(0xFF10B981),
                            label: '${project.doneCount} done'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Member count + productivity score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_outline,
                                color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text('${project.memberIds.length} thành viên',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: productivityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$productivityLabel ($productivityScore%)',
                            style: TextStyle(
                                color: productivityColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: project.progress,
                              backgroundColor: const Color(0xFF1E2235),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accentColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(project.progress * 100).toInt()}%',
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
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
}

class _StatDot extends StatelessWidget {
  final Color color;
  final String label;
  const _StatDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// ════════════════════════════════════════
// Project Dialog (Create / Edit)
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
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
}
