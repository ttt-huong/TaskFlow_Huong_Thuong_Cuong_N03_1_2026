import '../../models/user_model.dart';
import '../user_repository.dart';
import '../mocks/list_user.dart';

class LocalUserRepository implements UserRepository {
  final ListUser _listUser = ListUser(); // Singleton instance giả lập

  @override
  Future<List<UserModel>> getUsers() async {
    return _listUser.users;
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    return _listUser.findById(id);
  }

  @override
  Future<void> addUser(UserModel user) async {
    _listUser.create(user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    _listUser.edit(
      user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    _listUser.delete(id);
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    return _listUser.thongKe;
  }
}
