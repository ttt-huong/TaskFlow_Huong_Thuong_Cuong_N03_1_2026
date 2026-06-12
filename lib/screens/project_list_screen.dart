import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../core/app_colors.dart';
import '../widgets/common/skeleton_loader.dart';
import 'project_task_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      await projectProvider.loadProjects(auth.currentUser!);
      await projectProvider.loadAllUsers();
      
      // Nạp thống kê cho các dự án sau khi tải dự án xong
      final projectIds = projectProvider.projects.map((p) => p.id).toList();
      if (mounted) {
        Provider.of<TaskProvider>(context, listen: false).loadProjectStats(projectIds);
      }
    }
  }

  Color _getProjectStatusColor(double progress) {
    if (progress >= 100.0) return AppColors.done;
    if (progress > 0) return AppColors.primary;
    return AppColors.grey;
  }

  String _getProjectStatusText(double progress, int total) {
    if (total == 0) return 'Chưa có task';
    if (progress >= 100.0) return 'Đã hoàn thành';
    if (progress > 0) return 'Đang tiến hành';
    return 'Mới khởi tạo';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isManager = authProvider.currentUser?.isManager ?? false;
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dự án',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              '${projectProvider.projects.length} dự án đang tham gia',
              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showCreateProjectDialog(context),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isManager ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                      color: isManager ? AppColors.primary : Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isManager
                          ? 'Xin chào, ${authProvider.currentUser?.name ?? "Quản lý"} 👑'
                          : 'Xin chào, ${authProvider.currentUser?.name ?? "Thành viên"} 👤',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: projectProvider.isLoading
                    ? const SkeletonProjectList()
                    : projectProvider.projects.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryText.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.secondaryText),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        isManager ? 'Hãy tạo dự án đầu tiên.' : 'Không có dự án nào',
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Kéo xuống để tải lại dữ liệu hoặc tạo dự án mới.',
                                        style: TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: projectProvider.projects.length,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemBuilder: (context, index) {
                              final project = projectProvider.projects[index];
                              
                              // Lấy stats từ TaskProvider
                              final projectStats = taskProvider.projectStats[project.id] ?? {
                                'total': 0,
                                'done': 0,
                                'progress': 0.0,
                                'todo': 0,
                                'doing': 0,
                                'reviewing': 0
                              };

                              final int total = projectStats['total'] ?? 0;
                              final int done = projectStats['done'] ?? 0;
                              final double progress = (projectStats['progress'] as num?)?.toDouble() ?? 0.0;

                              return Card(
                                color: Colors.white,
                                surfaceTintColor: Colors.transparent,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
                                ),
                                elevation: 0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProjectTaskScreen(
                                          projectId: project.id,
                                          projectName: project.name,
                                        ),
                                      ),
                                    );
                                    // reload stats when returning from project tasks screen
                                    if (mounted) {
                                      final pIds = projectProvider.projects.map((p) => p.id).toList();
                                      taskProvider.loadProjectStats(pIds);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                project.name,
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getProjectStatusColor(progress).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getProjectStatusText(progress, total),
                                                style: TextStyle(
                                                  color: _getProjectStatusColor(progress),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          project.description.isEmpty
                                              ? 'Không có mô tả dự án.'
                                              : project.description,
                                          style: const TextStyle(
                                            color: AppColors.secondaryText,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        // Progress Bar
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Tiến độ dự án',
                                              style: TextStyle(
                                                color: AppColors.text.withValues(alpha: 0.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${progress.toStringAsFixed(0)}% ($done/$total tasks)',
                                              style: const TextStyle(
                                                color: AppColors.secondaryText,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: total == 0 ? 0.0 : done / total,
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            valueColor: AlwaysStoppedAnimation<Color>(_getProjectStatusColor(progress)),
                                            minHeight: 8,
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
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    final selectableUsers = projectProvider.allUsers
        .where((u) => currentUser == null || u.id != currentUser.id)
        .toList();

    final List<String> selectedMemberIds = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Tạo dự án mới',
                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên dự án',
                        labelStyle: TextStyle(color: AppColors.secondaryText),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả dự án',
                        labelStyle: TextStyle(color: AppColors.secondaryText),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chọn thành viên tham gia:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SizedBox(
                        height: 150,
                        child: selectableUsers.isEmpty
                            ? const Center(
                                child: Text(
                                  'Không tìm thấy thành viên khác.',
                                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: selectableUsers.length,
                                itemBuilder: (context, index) {
                                  final user = selectableUsers[index];
                                  final isChecked = selectedMemberIds.contains(user.id);
                                  return CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppColors.primary,
                                    title: Text(user.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                    value: isChecked,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selectedMemberIds.add(user.id);
                                        } else {
                                          selectedMemberIds.remove(user.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();
                    if (name.isNotEmpty) {
                      final List<String> finalMemberIds = [];
                      if (currentUser != null) {
                        finalMemberIds.add(currentUser.id);
                      }
                      finalMemberIds.addAll(selectedMemberIds);

                      await projectProvider.createProject(name, desc, finalMemberIds);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Tạo', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
