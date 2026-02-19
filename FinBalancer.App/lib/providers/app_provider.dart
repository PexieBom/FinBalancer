import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/auth_result.dart';
import '../services/auth_api_service.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _displayNameKey = 'user_display_name';
  static const String _loggedInKey = 'logged_in';
  final AuthApiService _authApi = AuthApiService();

  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _splashComplete = false;
  String? _token;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get splashComplete => _splashComplete;
  String? get token => _token;
  User? get user => _user;

  /// Završava kad je provjera spremljenog sessiona gotova.
  Future<void> get sessionCheckComplete => _sessionCheckFuture;
  late Future<void> _sessionCheckFuture;

  AppProvider() {
    _sessionCheckFuture = _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _isLoggedIn = _token != null && _token!.trim().isNotEmpty;
    if (_isLoggedIn && _token != null) {
      ApiService.authToken = _token;
      final email = prefs.getString(_userKey);
      final userId = prefs.getString(_userIdKey);
      final displayName = prefs.getString(_displayNameKey);
      if (email != null) {
        _user = User(
          id: userId ?? '',
          email: email,
          displayName: displayName ?? email.split('@').first,
        );
      }
    } else {
      ApiService.authToken = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveAuth(String token, String email, String displayName, {String userId = ''}) async {
    _token = token;
    ApiService.authToken = token;
    _user = User(id: userId, email: email, displayName: displayName);
    _isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, email);
    if (userId.isNotEmpty) await prefs.setString(_userIdKey, userId);
    await prefs.setString(_displayNameKey, displayName);
    await prefs.setBool(_loggedInKey, true);
    notifyListeners();
  }

  Future<void> _clearAuth() async {
    _token = null;
    _user = null;
    ApiService.authToken = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_displayNameKey);
    await prefs.setBool(_loggedInKey, false);
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final result = await _authApi.login(email, password);
      if (result.success && result.token != null && result.user != null) {
        await _saveAuth(
          result.token!,
          result.user!.email,
          result.user!.displayName,
          userId: result.user!.id,
        );
        return null;
      }
      return result.error ?? 'Login failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> register(String email, String password, String displayName) async {
    try {
      final result = await _authApi.register(email, password, displayName);
      if (result.success && result.token != null && result.user != null) {
        await _saveAuth(
          result.token!,
          result.user!.email,
          result.user!.displayName,
          userId: result.user!.id,
        );
        return null;
      }
      return result.error ?? 'Registration failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> loginWithGoogle(String googleId, String email, String? displayName) async {
    try {
      final result = await _authApi.loginWithGoogle(googleId, email, displayName);
      if (result.success && result.token != null && result.user != null) {
        await _saveAuth(
          result.token!,
          result.user!.email,
          result.user!.displayName,
          userId: result.user!.id,
        );
        return null;
      }
      return result.error ?? 'Google sign-in failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> loginWithApple(String appleId, String? email, String? displayName) async {
    try {
      final result = await _authApi.loginWithApple(appleId, email, displayName);
      if (result.success && result.token != null && result.user != null) {
        await _saveAuth(
          result.token!,
          result.user!.email,
          result.user!.displayName,
          userId: result.user!.id,
        );
        return null;
      }
      return result.error ?? 'Apple sign-in failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<AuthResult?> requestPasswordReset(String email, {bool dev = false}) async {
    try {
      final result = await _authApi.requestPasswordReset(email, dev: dev);
      return result.success ? result : null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> resetPassword(String token, String newPassword) async {
    try {
      final result = await _authApi.resetPassword(token, newPassword);
      if (result.success && result.token != null && result.user != null) {
        await _saveAuth(
          result.token!,
          result.user!.email,
          result.user!.displayName,
          userId: result.user!.id,
        );
        return null;
      }
      return result.error ?? 'Reset failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    await _clearAuth();
  }

  void completeSplash() {
    _splashComplete = true;
    notifyListeners();
  }

  /// Lokalni login bez API-ja (za brzi pristup dok API nije dostupan)
  Future<void> loginLocal() async {
    await _saveAuth('local_mock', 'local@finbalancer.app', 'Local User');
  }
}
