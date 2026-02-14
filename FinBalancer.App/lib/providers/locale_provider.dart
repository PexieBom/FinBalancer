import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'user_locale';
  static const String _currencyKey = 'user_currency';
  static const String _themeKey = 'user_theme';

  final ApiService _api = ApiService();

  Locale _locale = const Locale('en');
  String _currency = 'EUR';
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String get localeCode => _locale.languageCode;
  String get themeModeString => _themeMode == ThemeMode.light ? 'light' : _themeMode == ThemeMode.dark ? 'dark' : 'system';

  LocaleProvider() {
    _loadFromStorage();
    _loadFromApi();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    final savedCurrency = prefs.getString(_currencyKey);
    final savedTheme = prefs.getString(_themeKey);
    if (savedLocale != null) _locale = Locale(savedLocale);
    if (savedCurrency != null) _currency = savedCurrency;
    if (savedTheme != null) {
      _themeMode = savedTheme == 'light' ? ThemeMode.light : savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> _loadFromApi() async {
    try {
      final prefs = await _api.getUserPreferences();
      _locale = Locale(prefs['locale'] as String? ?? 'en');
      _currency = prefs['currency'] as String? ?? 'EUR';
      final theme = prefs['theme'] as String? ?? 'system';
      _themeMode = theme == 'light' ? ThemeMode.light : theme == 'dark' ? ThemeMode.dark : ThemeMode.system;
      await _saveToStorage();
      notifyListeners();
    } catch (_) {
      // API may be unavailable, keep local values
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.languageCode);
    await prefs.setString(_currencyKey, _currency);
    await prefs.setString(_themeKey, themeModeString);
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    await _saveToStorage();
    try {
      await _api.updateUserPreferences(newLocale.languageCode, _currency, theme: themeModeString);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    _currency = newCurrency;
    await _saveToStorage();
    try {
      await _api.updateUserPreferences(_locale.languageCode, newCurrency, theme: themeModeString);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveToStorage();
    try {
      await _api.updateUserPreferences(_locale.languageCode, _currency, theme: themeModeString);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> updatePreferences(String localeCode, String currencyCode, {String? theme}) async {
    _locale = Locale(localeCode);
    _currency = currencyCode;
    if (theme != null) {
      _themeMode = theme == 'light' ? ThemeMode.light : theme == 'dark' ? ThemeMode.dark : ThemeMode.system;
    }
    await _saveToStorage();
    try {
      await _api.updateUserPreferences(localeCode, currencyCode, theme: theme ?? themeModeString);
    } catch (_) {}
    notifyListeners();
  }
}
