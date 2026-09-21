import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'database.dart';
import 'app_preferences.dart';

class LocalAuthService {
  LocalAuthService._();

  static final LocalAuthService instance = LocalAuthService._();
  String? _pendingEmail;
  String? _pendingCode;
  bool _codeVerified = false;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = _normalize(email);
    if (await GymDatabase.instance.findUser(normalized) != null) return false;
    await GymDatabase.instance.createUser(
      name: name.trim(),
      email: normalized,
      passwordHash: _hash(password),
    );
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    final user = await GymDatabase.instance.findUser(_normalize(email));
    if (user == null || user['password_hash'] != _hash(password)) return false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_email', user['email'] as String);
    await AppPreferences.instance.saveAuthenticatedUser(
      user['email'] as String,
      user['name'] as String,
    );
    return true;
  }

  Future<String?> requestPasswordReset(String email) async {
    final normalized = _normalize(email);
    if (await GymDatabase.instance.findUser(normalized) == null) return null;
    final code = (100000 + Random.secure().nextInt(900000)).toString();
    _pendingEmail = normalized;
    _pendingCode = code;
    _codeVerified = false;
    return code;
  }

  bool verifyResetCode(String code) {
    _codeVerified = _pendingCode != null && code.trim() == _pendingCode;
    return _codeVerified;
  }

  Future<bool> resetPassword(String password) async {
    final email = _pendingEmail;
    if (email == null || !_codeVerified) return false;
    await GymDatabase.instance.updatePassword(email, _hash(password));
    _pendingEmail = null;
    _pendingCode = null;
    _codeVerified = false;
    return true;
  }

  String? get pendingEmail => _pendingEmail;

  String _normalize(String email) => email.trim().toLowerCase();

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();
}
