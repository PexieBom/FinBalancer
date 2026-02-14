import 'user.dart';

class AuthResult {
  final bool success;
  final String? token;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.token,
    this.user,
    this.error,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] as bool? ?? false,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      error: json['error'] as String?,
    );
  }
}
