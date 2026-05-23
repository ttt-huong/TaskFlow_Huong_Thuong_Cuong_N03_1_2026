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
    // Để cho đơn giản trong phiên bản này, nếu user đã đăng nhập Firebase, chúng ta cần fetch document của họ.
    // Nếu ứng dụng đang offline, có thể lấy từ SQLite hoặc bỏ qua
    return null; // Tạm thời để trống hoặc bạn có thể xử lý việc lưu currentUser session locally.
  }
}
