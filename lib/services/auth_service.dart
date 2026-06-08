import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sqlite_service.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final SQLiteService _sqliteService = SQLiteService();

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    if (_isFirebaseReady) {
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (doc.exists) {
          final user = UserModel.fromMap(doc.data()!, doc.id);
          await _sqliteService.cacheUser(user);
          return user;
        }
        return null;
      } catch (e) {
        // Firebase thất bại (mất mạng, timeout…) → fallback sang SQLite
        return _loginLocally(email, password);
      }
    } else {
      // Firebase chưa khởi tạo → dùng SQLite
      return _loginLocally(email, password);
    }
  }

  /// Xác thực offline bằng dữ liệu đã cache trong SQLite.
  /// Chỉ thành công nếu user đã từng đăng nhập online trước đó.
  /// KHÔNG có tài khoản mặc định / hardcode — toàn bộ đã bị xóa vì lý do bảo mật.
  Future<UserModel?> _loginLocally(String email, String password) async {
    final localUsers = await _sqliteService.getLocalUsers();

    // Dùng firstWhereOrNull để trả về null thay vì ném StateError
    return localUsers.firstWhereOrNull(
      (u) => u.email == email && u.password == password,
    );
  }

  Future<UserModel> register(
      String email, String password, String name, String role) async {
    final uid = const Uuid().v4();
    final newUser = UserModel(
      id: uid,
      name: name,
      email: email,
      password: password,
      role: role,
    );

    if (_isFirebaseReady) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final firebaseUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          password: password,
          role: role,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.id)
            .set(firebaseUser.toMap());
        await _sqliteService.cacheUser(firebaseUser);
        return firebaseUser;
      } catch (e) {
        // Đăng ký online thất bại → lưu offline, chờ sync
        await _sqliteService.cacheUser(newUser);
        return newUser;
      }
    } else {
      // Firebase chưa sẵn sàng → lưu offline
      await _sqliteService.cacheUser(newUser);
      return newUser;
    }
  }

  Future<void> logout() async {
    if (_isFirebaseReady) {
      await _auth.signOut();
    }
  }

  UserModel? getCurrentUserLocally(Map<String, dynamic>? data) {
    if (_isFirebaseReady && _auth.currentUser != null && data != null) {
      return UserModel.fromMap(data, _auth.currentUser!.uid);
    }
    return null;
  }
}
