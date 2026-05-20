import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> register(UserModel user);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
