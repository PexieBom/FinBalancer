import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;
  bool _step2 = false; // true = enter new password with token

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestReset() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = 'Enter your email');
      return;
    }
    setState(() { _isLoading = true; _error = null; _success = null; });
    // dev: true returns token in response for mock/testing (no email sent)
    final result = await context.read<AppProvider>().requestPasswordReset(
          _emailController.text.trim(),
          dev: true,
        );
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _success = result.token != null
              ? 'Mock: Use this token: ${result.token}'
              : 'Check your email for reset link';
          _step2 = true;
          if (result.token != null) {
            _tokenController.text = result.token!;
          }
        } else {
          _error = 'Request failed';
        }
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (_tokenController.text.isEmpty || _passwordController.text.length < 6) {
      setState(() => _error = 'Token and password (min 6 chars) required');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final err = await context.read<AppProvider>().resetPassword(
          _tokenController.text.trim(),
          _passwordController.text,
        );
    if (mounted) {
      setState(() { _isLoading = false; _error = err; });
      if (err == null) Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_reset, size: 64, color: AppTheme.accentColor),
              const SizedBox(height: 24),
              Text(_step2 ? 'Set New Password' : 'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  _step2
                      ? 'Enter the token from email and your new password'
                      : 'Enter your email to receive a reset link',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              if (!_step2) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ] else ...[
                TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(labelText: 'Reset Token (from email)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 16),
                Text(_success!, style: const TextStyle(color: AppTheme.incomeColor)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppTheme.expenseColor)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_step2 ? _handleResetPassword : _handleRequestReset),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_step2 ? 'Reset Password' : 'Send Reset Link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
