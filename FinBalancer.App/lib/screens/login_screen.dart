import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;

import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final err = await context.read<AppProvider>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    setState(() {
      _isLoading = false;
      _error = err;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId: AppConfig.googleWebClientId,
      );
      await googleSignIn.signOut(); // Clear previous account so user can switch
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
      setState(() {
        _isLoading = false;
        _error = err;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
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
      setState(() {
        _isLoading = false;
        _error = err;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleLocalLogin() async {
    setState(() => _isLoading = true);
    await context.read<AppProvider>().loginLocal();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                const SizedBox(height: 40),
                Icon(Icons.account_balance_wallet_rounded, size: 80, color: AppTheme.accentColor),
                const SizedBox(height: 24),
                Text('Sign in to manage your finances', textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 32),
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
                    onPressed: _isLoading ? null : _handleEmailLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create Account'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                  child: const Text('Forgot Password?'),
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
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading ? null : _handleLocalLogin,
                  child: Text('Skip - Local mode (no API)', style: TextStyle(color: Colors.grey.shade600)),
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
