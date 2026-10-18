import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  static const String _registeredKey = 'registered_users';
  static const String _sessionKey = 'session_user_id';
  static const String _usersAsset = 'assets/data/users.json';

  final StorageService _storage;
  List<AppUser>? _mockUsers;

  AuthRepository(this._storage);

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<List<AppUser>> _loadMockUsers() async {
    if (_mockUsers != null) return _mockUsers!;
    final raw = await rootBundle.loadString(_usersAsset);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _mockUsers = (data['users'] as List)
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
    return _mockUsers!;
  }

  List<AppUser> _loadRegisteredUsers() {
    final data = _storage.getJson(_registeredKey);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AppUser>> _allUsers() async {
    final mock = await _loadMockUsers();
    return [...mock, ..._loadRegisteredUsers()];
  }

  Future<AppUser?> restoreSession() async {
    final id = _storage.getString(_sessionKey);
    if (id == null) return null;
    final users = await _allUsers();
    for (final user in users) {
      if (user.id == id) return user;
    }
    await _storage.remove(_sessionKey);
    return null;
  }

  Future<AppUser> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final users = await _allUsers();
    final hash = hashPassword(password);
    for (final user in users) {
      if (user.email.toLowerCase() == normalized) {
        if (user.passwordHash == hash) {
          await _storage.setString(_sessionKey, user.id);
          return user;
        }
        throw const AuthException('Incorrect password. Please try again.');
      }
    }
    throw const AuthException('No account found with this email.');
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final users = await _allUsers();
    final exists = users.any((u) => u.email.toLowerCase() == normalized);
    if (exists) {
      throw const AuthException('An account with this email already exists.');
    }
    final user = AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalized,
      passwordHash: hashPassword(password),
    );
    final registered = _loadRegisteredUsers()..add(user);
    await _storage.setJson(
      _registeredKey,
      registered.map((u) => u.toJson()).toList(),
    );
    await _storage.setString(_sessionKey, user.id);
    return user;
  }

  Future<void> logout() async {
    await _storage.remove(_sessionKey);
  }
}
