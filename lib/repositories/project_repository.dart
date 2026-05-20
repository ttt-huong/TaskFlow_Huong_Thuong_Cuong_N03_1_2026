import '../models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects();
  Future<List<ProjectModel>> getProjectsByUser(String userId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> addProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<Map<String, int>> getStatistics();
}
