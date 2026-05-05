import '../auth_repository.dart';
import '../../models/user_model.dart';
import '../mocks/list_user.dart';

class LocalAuthRepository implements AuthRepository {
  final ListUser _listUser = ListUser();
  UserModel? _currentUser;

  @override
  Future<UserModel?> login(String email, String password) async {
    // Giả lập delay mạng
    await Future.delayed(const Duration(milliseconds: 500));
    
    final user = _listUser.findByEmail(email);
    
    if (user != null && user.password == password) {
      _currentUser = user;
      return user;
    }
    
    return null;
  }

  @override
  Future<void> register(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _listUser.create(user);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}
