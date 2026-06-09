import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> register(UserModel user);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> updateName(String userId, String newName);
  Future<({bool success, String message})> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
}
