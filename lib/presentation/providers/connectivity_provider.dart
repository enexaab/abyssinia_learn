import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _online = true;

  bool get isOnline => _online;

  Future<void> initialize() async {
    try {
      _apply(await _connectivity.checkConnectivity());
      _subscription = _connectivity.onConnectivityChanged.listen(_apply);
    } catch (_) {
      _online = true;
    }
  }

  void _apply(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online != _online) {
      _online = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
