import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/impl/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  // QUAN TRỌNG: Không bao giờ tin tưởng quyền Manager khi Offline
  bool get isManager {
    if (_isOfflineMode) {
      return false; // Offline mặc định là Member/Guest hạn chế
    }
    return _currentUser?.role == 'manager';
  }

  AuthProvider() {
    restoreSession();
  }

  Future<void> restoreSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.getCurrentUser();
      _isOfflineMode = false;
    } catch (_) {
      _currentUser = null;
      _isOfflineMode = true;
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isOfflineMode = false;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email, password);

      if (_currentUser == null) {
        // Xác định có đang offline không để thông báo chính xác
        final bool offline = !Firebase.apps.isNotEmpty;

        _errorMessage = offline
            ? 'Ứng dụng đang ngoại tuyến. Vui lòng kết nối mạng để đăng nhập lần đầu.'
            : 'Email hoặc mật khẩu không đúng. Vui lòng thử lại.';
        _isOfflineMode = offline;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Đăng nhập thành công — xác định chế độ
      bool offline = true;
      try {
        if (Firebase.apps.isNotEmpty &&
            FirebaseAuth.instance.currentUser != null) {
          offline = false;
        }
      } catch (_) {
        offline = true;
      }
      _isOfflineMode = offline;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      bool offline = false;
      if (msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('connection')) {
        _errorMessage =
            'Ứng dụng đang ngoại tuyến. Vui lòng thử lại nếu bạn đã từng đăng nhập trước đó.';
        offline = true;
      } else if (msg.contains('wrong-password') ||
          msg.contains('invalid-credential')) {
        _errorMessage = 'Email hoặc mật khẩu không đúng.';
      } else if (msg.contains('user-not-found')) {
        _errorMessage = 'Tài khoản không tồn tại.';
      } else {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.';
      }
      _isLoading = false;
      _isOfflineMode = offline;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String role) async {
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

  /// Cập nhật tên — cập nhật cả local state ngay lập tức
  Future<bool> updateName(String newName) async {
    final user = _currentUser;
    if (user == null) return false;
    final success = await _authRepository.updateName(user.id, newName);
    if (success) {
      _currentUser = UserModel(
        id: user.id,
        name: newName,
        email: user.email,
        password: user.password,
        role: user.role,
        avatarChar:
            newName.isNotEmpty ? newName[0].toUpperCase() : user.avatarChar,
      );
      notifyListeners();
    }
    return success;
  }

  /// Đổi mật khẩu — cập nhật local cache nếu thành công
  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return (success: false, message: 'Chưa đăng nhập.');
    }
    final result = await _authRepository.changePassword(
      userId: user.id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (result.success) {
      // Cập nhật password trong local model
      _currentUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: newPassword,
        role: user.role,
        avatarChar: user.avatarChar,
      );
      notifyListeners();
    }
    return result;
  }
}
