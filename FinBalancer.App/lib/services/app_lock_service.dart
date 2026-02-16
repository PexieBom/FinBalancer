import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockService {
  static const String _pinKey = 'app_lock_pin';
  static const String _enabledKey = 'app_lock_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> isEnabled() async {
    if (!isMobile) return false;
    final v = await _storage.read(key: _enabledKey);
    return v == '1';
  }

  Future<void> enable(String pin) async {
    if (!isMobile) return;
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _enabledKey, value: '1');
  }

  Future<void> disable() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _enabledKey);
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (!await verify(oldPin)) return false;
    await _storage.write(key: _pinKey, value: newPin);
    return true;
  }

  Future<bool> verify(String pin) async {
    if (!isMobile) return false;
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored == pin;
  }
}
