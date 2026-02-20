import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'api_service.dart';

/// Upravlja FCM tokenom i registracijom za push notifikacije.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;

  PushNotificationService._();

  final ApiService _api = ApiService();
  String? _lastToken;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Pozovi nakon uspješnog logina.
  Future<void> registerTokenIfNeeded(String? authToken) async {
    if (authToken == null || authToken.isEmpty) return;
    if (!_initialized) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (token == _lastToken) return;

      final platform = (!kIsWeb && Platform.isIOS) ? 'ios' : 'android';
      await _api.registerDeviceToken(token: token, platform: platform);
      _lastToken = token;
    } catch (_) {
      // Firebase nije konfiguriran ili nema token
    }
  }

  /// Ukloni token pri logoutu.
  Future<void> unregisterToken() async {
    if (_lastToken == null) return;
    try {
      await _api.unregisterDeviceToken(_lastToken!);
      _lastToken = null;
    } catch (_) {}
  }

  /// Inicijalizira - requesta dozvole (iOS) i postavlja background handler.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      _initialized = true;
    } catch (_) {
      // Firebase nije dostupan (npr. web bez config)
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
