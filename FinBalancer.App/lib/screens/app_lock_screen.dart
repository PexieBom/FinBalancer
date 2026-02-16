import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_lock_provider.dart';

/// Ekran za unos PIN-a pri otključavanju aplikacije.
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final List<String> _enteredDigits = [];
  static const int _pinLength = 4;
  String _error = '';

  void _onDigitPressed(String digit) {
    if (_enteredDigits.length >= _pinLength) return;
    setState(() {
      _enteredDigits.add(digit);
      _error = '';
    });
    if (_enteredDigits.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredDigits.isEmpty) return;
    setState(() {
      _enteredDigits.removeLast();
      _error = '';
    });
  }

  Future<void> _verifyPin() async {
    final pin = _enteredDigits.join();
    final ok = await context.read<AppLockProvider>().unlock(pin);
    if (!ok && mounted) {
      setState(() {
        _enteredDigits.clear();
        _error = _getInvalidPinText();
      });
      HapticFeedback.heavyImpact();
    }
  }

  String _getInvalidPinText() {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'hr') return 'Krivi PIN';
    if (locale == 'de') return 'Falscher PIN';
    if (locale == 'fr') return 'PIN incorrect';
    if (locale == 'es') return 'PIN incorrecto';
    if (locale == 'it') return 'PIN errato';
    return 'Invalid PIN';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 24),
              Text(
                _getEnterPinText(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _enteredDigits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppTheme.accent(context)
                          : theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  );
                }),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              _buildNumpad(theme),
            ],
          ),
        ),
      ),
    );
  }

  String _getEnterPinText() {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'hr') return 'Unesite PIN za pristup';
    if (locale == 'de') return 'PIN eingeben';
    if (locale == 'fr') return 'Entrez votre code';
    if (locale == 'es') return 'Introduce tu PIN';
    if (locale == 'it') return 'Inserisci il PIN';
    return 'Enter PIN to unlock';
  }

  Widget _buildNumpad(ThemeData theme) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 72, height: 72);
              }
              if (key == 'back') {
                return _NumpadButton(
                  icon: Icons.backspace_outlined,
                  onPressed: _onBackspace,
                );
              }
              return _NumpadButton(
                label: key,
                onPressed: () => _onDigitPressed(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _NumpadButton({
    this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Center(
              child: label != null
                  ? Text(
                      label!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    )
                  : Icon(icon, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
