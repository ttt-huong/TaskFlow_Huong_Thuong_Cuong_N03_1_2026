import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/impl/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  // QUAN TRỌNG: Không bao giờ tin tưởng quyền Manager khi Offline
  bool get isManager {
    if (_isOfflineMode) return false; // Offline mặc định là Member/Guest hạn chế
    return _currentUser?.role == 'manager';
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isOfflineMode = false;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email, password);
      
      bool offline = true;
      try {
        if (Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
          offline = false;
        }
      } catch (_) {
        offline = true;
      }
      _isOfflineMode = offline;

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isOfflineMode = true;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = UserModel(
        id: '',
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await _authRepository.register(user);
      // login automatically after register
      return await login(email, password);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _isOfflineMode = false;
    notifyListeners();
  }
}
