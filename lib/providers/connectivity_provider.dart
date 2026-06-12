import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// ConnectivityProvider — ChangeNotifier lắng nghe [ConnectivityService].
///
/// - Cung cấp [isOnline] cho toàn bộ widget tree thông qua Provider.
/// - Tự động gọi [onBackOnline] khi mạng khôi phục (offline → online).
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service = ConnectivityService.instance;

  bool _isOnline;
  bool get isOnline => _isOnline;

  /// Callback được gọi khi mạng trở lại — dùng để trigger sync.
  VoidCallback? _onBackOnline;

  StreamSubscription<bool>? _subscription;

  ConnectivityProvider() : _isOnline = ConnectivityService.instance.isOnline {
    _subscription = _service.onConnectivityChanged.listen((online) {
      final wasOffline = !_isOnline;
      _isOnline = online;
      notifyListeners();

      // Kích hoạt sync khi mạng vừa trở lại
      if (online && wasOffline) {
        _onBackOnline?.call();
      }
    });
  }

  bool _initialSyncDone = false;

  /// Được gọi bởi [ChangeNotifierProxyProvider] trong main.dart để inject
  /// callback sync sau khi các provider phụ thuộc đã sẵn sàng.
  void updateSyncCallback({required VoidCallback onBackOnline}) {
    _onBackOnline = onBackOnline;
    if (_isOnline && !_initialSyncDone) {
      _initialSyncDone = true;
      Future.microtask(() => _onBackOnline?.call());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
