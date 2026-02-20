import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_result.dart';

class AuthApiService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/auth';

  final http.Client _client = http.Client();

  Future<AuthResult> register(String email, String password, String displayName) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'displayName': displayName,
      }),
    );
    return _parseAuthResponse(response);
  }

  Future<AuthResult> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return _parseAuthResponse(response);
  }

  Future<AuthResult> loginWithGoogle(String googleId, String email, String? displayName) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login/google'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'providerId': googleId,
        'email': email,
        'displayName': displayName,
      }),
    );
    return _parseAuthResponse(response);
  }

  Future<AuthResult> loginWithApple(String appleId, String? email, String? displayName) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login/apple'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'providerId': appleId,
        'email': email,
        'displayName': displayName,
      }),
    );
    return _parseAuthResponse(response);
  }

  AuthResult _parseAuthResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return AuthResult.fromJson(decoded);
        }
      } catch (_) {}
    }
    String? errMsg;
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        errMsg = decoded['error'].toString();
      } else if (decoded is Map && decoded['title'] != null) {
        errMsg = decoded['title'].toString();
      }
    } catch (_) {
      final body = response.body.trim();
      if (body.isNotEmpty && body.length < 300 && !body.startsWith('<!')) {
        errMsg = body;
      }
    }
    return AuthResult(
      success: false,
      error: errMsg ?? 'Request failed (${response.statusCode})',
    );
  }

  Future<AuthResult> requestPasswordReset(String email, {bool dev = false}) async {
    final url = dev ? '$_baseUrl/password/reset-request?dev=true' : '$_baseUrl/password/reset-request';
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    return _parseAuthResponse(response);
  }

  Future<AuthResult> resetPassword(String token, String newPassword) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token, 'newPassword': newPassword}),
    );
    return _parseAuthResponse(response);
  }

  /// Change password for logged-in user. Requires auth token.
  Future<String?> changePassword(String authToken, String currentPassword, String newPassword) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/account/password/change'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode == 200) return null;
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        return decoded['error'] as String;
      }
    } catch (_) {}
    return 'Failed to change password';
  }
}
