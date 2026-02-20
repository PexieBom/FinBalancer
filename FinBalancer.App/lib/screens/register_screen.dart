import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;

import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../providers/app_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _appleSignInAvailable = false;

  @override
  void initState() {
    super.initState();
    apple.SignInWithApple.isAvailable().then((v) {
      if (mounted) setState(() => _appleSignInAvailable = v);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final err = await context.read<AppProvider>().register(
          _emailController.text.trim(),
          _passwordController.text,
          _displayNameController.text.trim().isEmpty
              ? _emailController.text.split('@').first
              : _displayNameController.text.trim(),
        );
    if (mounted) {
      setState(() { _isLoading = false; _error = err; });
      if (err == null) Navigator.pop(context);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId: AppConfig.googleWebClientId,
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }
      final googleId = account.id;
      final email = account.email;
      if (googleId == null || googleId.isEmpty || email == null || email.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Google account info incomplete. Please grant email permission.';
        });
        return;
      }
      final err = await context.read<AppProvider>().loginWithGoogle(
            googleId,
            email,
            account.displayName,
          );
      if (mounted) {
        setState(() { _isLoading = false; _error = err; });
        if (err == null) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final credential = await apple.SignInWithApple.getAppleIDCredential(
        scopes: [apple.AppleIDAuthorizationScopes.email, apple.AppleIDAuthorizationScopes.fullName],
      );
      final err = await context.read<AppProvider>().loginWithApple(
            credential.userIdentifier ?? credential.identityToken ?? '',
            credential.email,
            credential.givenName != null
                ? '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim()
                : null,
          );
      if (mounted) {
        setState(() { _isLoading = false; _error = err; });
        if (err == null) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
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
        child: webAdaptiveContent(
          context,
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Create Account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Register to start managing your finances',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppTheme.expenseColor)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or', style: TextStyle(color: Colors.grey.shade600))),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: Icon(Icons.g_mobiledata, size: 28, color: Colors.grey.shade700),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade400)),
                  ),
                ),
                if (_appleSignInAvailable) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleAppleSignIn,
                      icon: Icon(Icons.apple, size: 24, color: Colors.grey.shade800),
                      label: const Text('Continue with Apple'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
