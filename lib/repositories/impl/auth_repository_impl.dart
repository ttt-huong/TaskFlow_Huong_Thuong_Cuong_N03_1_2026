import '../auth_repository.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService();

  @override
  Future<UserModel?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  @override
  Future<void> register(UserModel user) async {
    await _authService.register(user.email, user.password, user.name, user.role);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return null;
  }

  @override
  Future<bool> updateName(String userId, String newName) async {
    return await _authService.updateName(userId, newName);
  }

  @override
  Future<({bool success, String message})> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _authService.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

