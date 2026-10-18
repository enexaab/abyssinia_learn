import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _busy = false;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isBusy => _busy;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _user = await _repository.restoreSession();
    } catch (_) {
      _user = null;
    }
    _status =
        _user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) {
    return _run(() => _repository.login(email, password));
  }

  Future<bool> register(String name, String email, String password) {
    return _run(
      () => _repository.register(name: name, email: email, password: password),
    );
  }

  Future<bool> _run(Future<AppUser> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _user = await action();
      _status = AuthStatus.authenticated;
      _busy = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    }
    _busy = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
