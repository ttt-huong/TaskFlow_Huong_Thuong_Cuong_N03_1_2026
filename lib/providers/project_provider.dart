import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../repositories/impl/project_repository_impl.dart';
import '../repositories/impl/user_repository_impl.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepositoryImpl _projectRepository = ProjectRepositoryImpl();
  final UserRepositoryImpl _userRepository = UserRepositoryImpl();

  List<ProjectModel> _projects = [];
  List<ProjectModel> get projects => _projects;

  List<ProjectModel> _filteredProjects = [];
  List<ProjectModel> get filteredProjects => _filteredProjects;

  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _filterStatus = 'All'; // All | Active | Completed
  String get filterStatus => _filterStatus;

  // ── Dashboard Summary ──
  int get totalProjects => _projects.length;
  int get completedProjects => _projects.where((p) => p.progress >= 1.0).length;
  int get totalTasks => _projects.fold(
      0, (sum, p) => sum + p.todoCount + p.doingCount + p.doneCount);
  int get completedTasks => _projects.fold(0, (sum, p) => sum + p.doneCount);
  double get overallCompletion =>
      totalTasks == 0 ? 0 : (completedTasks / totalTasks * 100);

  Future<void> loadProjects(UserModel currentUser) async {
    _isLoading = true;
    notifyListeners();

    if (currentUser.isManager) {
      _projects = await _projectRepository.getProjects();
    } else {
      _projects = await _projectRepository.getProjectsByUser(currentUser.id);
    }

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllUsers() async {
    _allUsers = await _userRepository.getUsers();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<ProjectModel> result = List.from(_projects);

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    // Filter status
    if (_filterStatus == 'Active') {
      result = result.where((p) => p.progress < 1.0).toList();
    } else if (_filterStatus == 'Completed') {
      result = result.where((p) => p.progress >= 1.0).toList();
    }

    _filteredProjects = result;
  }

  Future<void> createProject(
      String name, String description, List<String> memberIds) async {
    final newProject = ProjectModel(
      id: '',
      name: name,
      description: description,
      memberIds: memberIds,
    );
    await _projectRepository.addProject(newProject);
    _projects.add(newProject);
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _projectRepository.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    await _projectRepository.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    _applyFilters();
    notifyListeners();
  }

  /// Đồng bộ các Project đang pending lên Firestore
  Future<void> syncPending() async {
    await _projectRepository.syncPendingProjects();
  }
}

