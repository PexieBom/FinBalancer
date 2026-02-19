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
    return AuthResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<AuthResult> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return AuthResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
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
    return AuthResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
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
    return AuthResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<AuthResult> requestPasswordReset(String email, {bool dev = false}) async {
    final url = dev ? '$_baseUrl/password/reset-request?dev=true' : '$_baseUrl/password/reset-request';
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    return AuthResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<AuthResult> resetPassword(String token, String newPassword) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token, 'newPassword': newPassword}),
    );
    return AuthResult.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
}
