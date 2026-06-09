import '../user_repository.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../services/sqlite_service.dart';
import '../../services/connectivity_service.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final SQLiteService _sqliteService = SQLiteService();

  bool get _isOnline => ConnectivityService.instance.isOnline;

  @override
  Future<List<UserModel>> getUsers() async {
    if (_isOnline) {
      try {
        final users = await _firebaseService.getUsers();
        for (var u in users) {
          await _sqliteService.cacheUser(u);
        }
        return users;
      } catch (e) {
        return _sqliteService.getLocalUsers();
      }
    } else {
      return _sqliteService.getLocalUsers();
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    if (_isOnline) {
      try {
        final user = await _firebaseService.getUserById(id);
        if (user != null) {
          await _sqliteService.cacheUser(user);
        }
        return user;
      } catch (e) {
        final localUsers = await _sqliteService.getLocalUsers();
        try {
          return localUsers.firstWhere((u) => u.id == id);
        } catch (_) {
          return null;
        }
      }
    } else {
      final localUsers = await _sqliteService.getLocalUsers();
      try {
        return localUsers.firstWhere((u) => u.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<void> addUser(UserModel user) async {
    if (_isOnline) {
      await _firebaseService.saveUser(user);
    }
    await _sqliteService.cacheUser(user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    if (_isOnline) {
      await _firebaseService.saveUser(user);
    }
    await _sqliteService.cacheUser(user);
  }

  @override
  Future<void> deleteUser(String id) async {
    // Không hỗ trợ xóa offline
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final users = await getUsers();
    return {'total': users.length};
  }
}
