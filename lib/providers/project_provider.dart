import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../repositories/impl/project_repository_impl.dart';
import '../models/user_model.dart';
import '../repositories/impl/user_repository_impl.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepositoryImpl _projectRepository = ProjectRepositoryImpl();
  final UserRepositoryImpl _userRepository = UserRepositoryImpl();

  List<ProjectModel> _projects = [];
  List<ProjectModel> get projects => _projects;

  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProjects(UserModel currentUser) async {
    _isLoading = true;
    notifyListeners();

    if (currentUser.isManager) {
      _projects = await _projectRepository.getProjects();
    } else {
      _projects = await _projectRepository.getProjectsByUser(currentUser.id);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllUsers() async {
    _allUsers = await _userRepository.getUsers();
    notifyListeners();
  }

  Future<void> createProject(String name, String description, List<String> memberIds) async {
    final newProject = ProjectModel(
      id: '',
      name: name,
      description: description,
      memberIds: memberIds,
    );
    await _projectRepository.addProject(newProject);
    _projects.add(newProject);
    notifyListeners();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _projectRepository.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    await _projectRepository.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }
}
