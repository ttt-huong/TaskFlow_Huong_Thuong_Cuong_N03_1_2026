import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// ConnectivityService — Singleton quản lý trạng thái kết nối mạng.
///
/// - Wrap [connectivity_plus] để phát hiện thay đổi mạng real-time.
/// - Xác nhận internet thực sự bằng DNS lookup (không chỉ dựa vào WiFi/Mobile connected).
/// - Cache kết quả [isOnline] để các repository dùng đồng bộ, không cần DNS lookup riêng.
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Stream phát [true] khi có mạng, [false] khi mất mạng.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Khởi tạo service: kiểm tra trạng thái ban đầu và bắt đầu lắng nghe.
  /// Gọi một lần duy nhất trong [main()] trước [runApp].
  Future<void> init() async {
    // Kiểm tra trạng thái ban đầu
    _isOnline = await _checkRealInternet();

    // Lắng nghe thay đổi kết nối từ hệ thống
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final hasConnectivity = results.any((r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet);

        if (!hasConnectivity) {
          // Hệ thống báo mất kết nối → tin ngay, không cần verify
          _updateStatus(false);
        } else {
          // Hệ thống báo có kết nối → verify bằng DNS để chắc chắn
          final hasInternet = await _checkRealInternet();
          _updateStatus(hasInternet);
        }
      },
    );
  }

  /// Kiểm tra internet thực sự bằng DNS lookup.
  Future<bool> _checkRealInternet() async {
    // Trên Web, InternetAddress.lookup không được hỗ trợ, tin vào connectivity_plus
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup('firebase.google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final fallback = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        return fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  void _updateStatus(bool isOnline) {
    if (_isOnline == isOnline) return; // Không phát nếu không đổi
    _isOnline = isOnline;
    _controller.add(_isOnline);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
