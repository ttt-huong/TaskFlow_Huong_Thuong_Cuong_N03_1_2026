import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task_model.dart';

class ProjectTaskScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  const ProjectTaskScreen({super.key, required this.projectId, required this.projectName});

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasksByProject(widget.projectId);
      Provider.of<ProjectProvider>(context, listen: false).loadAllUsers();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return Colors.redAccent;
      case 'doing':
        return Colors.orangeAccent;
      case 'reviewing':
        return Colors.blueAccent;
      case 'done':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isManager = authProvider.currentUser?.isManager ?? false;
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Lọc theo vai trò: Quyền Member chỉ thấy task của chính họ gán
    List<Task> roleFiltered = isManager
        ? taskProvider.tasks
        : taskProvider.tasks.where((task) => task.assignedTo == authProvider.currentUser?.id).toList();

    // Lọc tiếp theo bộ lọc trạng thái
    List<Task> finalFilteredTasks = roleFiltered;
    if (_selectedFilter != 'Tất cả') {
      finalFilteredTasks = roleFiltered
          .where((task) => task.status.toLowerCase() == _selectedFilter.toLowerCase() ||
              (task.status.toLowerCase() == 'reviewing' && _selectedFilter == 'Review'))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                fontSize: 22,
              ),
            ),
            Text(
              isManager
                  ? '${taskProvider.tasks.length} tasks'
                  : '${roleFiltered.length} tasks của bạn',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showAddTaskDialog(context, projectProvider),
                ),
              ),
            ),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Thanh Filter ngang
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tất cả', 'Todo', 'Doing', 'Review', 'Done'].map((tab) {
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
                              color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1E2235),
                              borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 20),

                  isManager
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2235),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tất cả thành viên',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ],
                          ),
                        )
                      : const Text(
                          'Chỉ hiển thị task được gán cho bạn',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: finalFilteredTasks.isEmpty
                        ? const Center(
                            child: Text(
                              'Không có công việc nào',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: finalFilteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = finalFilteredTasks[index];
                              final bool isReviewing = task.status.toLowerCase() == 'reviewing';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161926),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.01),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: _statusColor(task.status),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(task.status).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  task.status.toUpperCase(),
                                                  style: TextStyle(
                                                    color: _statusColor(task.status),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),

                                              // Nút Duyệt / Từ chối cho Manager
                                              if (isManager && isReviewing) ...[
                                                GestureDetector(
                                                  onTap: () => taskProvider.updateTaskStatus(task.id, 'doing'),
                                                  child: _buildActionButton('Từ chối', Colors.orangeAccent),
                                                ),
                                                const SizedBox(width: 6),
                                                GestureDetector(
                                                  onTap: () => taskProvider.updateTaskStatus(task.id, 'done'),
                                                  child: _buildActionButton('Duyệt', Colors.greenAccent),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.blue.withOpacity(0.15),
                                      child: Text(
                                        task.assignedTo.isNotEmpty ? task.assignedTo.substring(0, 1).toUpperCase() : '?',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildActionButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, ProjectProvider projectProvider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedUser = projectProvider.allUsers.isNotEmpty ? projectProvider.allUsers.first.id : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm nhiệm vụ mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedUser,
                    hint: const Text('Giao cho thành viên'),
                    items: projectProvider.allUsers.map((u) {
                      return DropdownMenuItem<String>(
                        value: u.id,
                        child: Text(u.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedUser = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();
                    if (title.isNotEmpty && selectedUser != null) {
                      await Provider.of<TaskProvider>(context, listen: false).createTask(
                        title,
                        desc,
                        widget.projectId,
                        selectedUser!,
                        DateTime.now().add(const Duration(days: 7)),
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
