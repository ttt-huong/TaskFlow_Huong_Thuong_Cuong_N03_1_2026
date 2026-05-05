import '../../models/project_model.dart';
import '../project_repository.dart';
import '../mocks/list_project.dart';

class LocalProjectRepository implements ProjectRepository {
  final ListProject _listProject = ListProject(); // Singleton instance giả lập

  @override
  Future<List<ProjectModel>> getProjects() async {
    return _listProject.projects;
  }

  @override
  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    return _listProject.projects.where((p) => p.memberIds.contains(userId)).toList();
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    return _listProject.findById(id);
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    _listProject.create(project);
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    _listProject.edit(
      project.id,
      name: project.name,
      description: project.description,
      memberIds: project.memberIds,
    );
  }

  @override
  Future<void> deleteProject(String id) async {
    _listProject.delete(id);
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    return _listProject.thongKe;
  }
}
