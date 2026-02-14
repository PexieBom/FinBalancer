import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static const String _loggedInKey = 'logged_in';
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _splashComplete = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get splashComplete => _splashComplete;

  AppProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    _isLoggedIn = false;
    notifyListeners();
  }

  void completeSplash() {
    _splashComplete = true;
    notifyListeners();
  }
}
