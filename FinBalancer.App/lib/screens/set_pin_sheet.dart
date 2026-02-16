import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_lock_provider.dart';

/// Bottom sheet za postavljanje ili promjenu PIN-a.
class SetPinSheet extends StatefulWidget {
  final bool isChanging;

  const SetPinSheet({super.key, this.isChanging = false});

  @override
  State<SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends State<SetPinSheet> {
  final List<String> _digits = [];
  static const int _pinLength = 4;
  int _step = 0;
  String? _savedPin;
  String? _oldPin;
  String _error = '';

  void _onDigit(String digit) {
    if (_digits.length >= _pinLength) return;

    setState(() {
      _error = '';
      _digits.add(digit);
      if (_digits.length == _pinLength) _onStepComplete();
    });
  }

  void _onBackspace() {
    setState(() {
      _error = '';
      if (_digits.isNotEmpty) _digits.removeLast();
    });
  }

  Future<void> _onStepComplete() async {
    final pin = _digits.join();
    if (widget.isChanging) {
      if (_step == 0) {
        final ok = await context.read<AppLockProvider>().verifyPin(pin);
        if (!ok && mounted) {
          setState(() {
            _error = _t('wrongPin');
            _digits.clear();
          });
          HapticFeedback.heavyImpact();
          return;
        }
        if (!mounted) return;
        _oldPin = pin;
        setState(() {
          _step = 1;
          _digits.clear();
        });
      } else if (_step == 1) {
        _savedPin = pin;
        setState(() {
          _step = 2;
          _digits.clear();
        });
      } else {
        if (pin != _savedPin) {
          setState(() {
            _error = _t('pinMismatch');
            _digits.clear();
          });
          HapticFeedback.heavyImpact();
        } else {
          _doChangePin();
        }
      }
    } else {
      if (_step == 0) {
        _savedPin = pin;
        setState(() {
          _step = 1;
          _digits.clear();
        });
      } else {
        if (pin != _savedPin) {
          setState(() {
            _error = _t('pinMismatch');
            _digits.clear();
          });
          HapticFeedback.heavyImpact();
        } else {
          _doSetPin();
        }
      }
    }
  }

  Future<void> _doChangePin() async {
    final lock = context.read<AppLockProvider>();
    final oldPin = _oldPin!;
    final newPin = _digits.join();
    final ok = await lock.changePin(oldPin, newPin);
    if (!ok && mounted) {
      setState(() {
        _error = _t('wrongPin');
        _step = 0;
        _oldPin = null;
        _savedPin = null;
        _digits.clear();
      });
      HapticFeedback.heavyImpact();
    } else if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _doSetPin() async {
    await context.read<AppLockProvider>().setPin(_digits.join());
    if (mounted) Navigator.pop(context, true);
  }

  String _t(String key) {
    final locale = Localizations.localeOf(context).languageCode;
    if (key == 'wrongPin') {
      if (locale == 'hr') return 'Krivi PIN';
      if (locale == 'de') return 'Falscher PIN';
      return 'Wrong PIN';
    }
    if (key == 'pinMismatch') {
      if (locale == 'hr') return 'PIN-ovi se ne podudaraju';
      if (locale == 'de') return 'PINs stimmen nicht überein';
      return 'PINs do not match';
    }
    if (key == 'enterPin') {
      if (locale == 'hr') return 'Unesite novi PIN';
      if (locale == 'de') return 'Neuen PIN eingeben';
      return 'Enter new PIN';
    }
    if (key == 'confirmPin') {
      if (locale == 'hr') return 'Potvrdite PIN';
      if (locale == 'de') return 'PIN bestätigen';
      return 'Confirm PIN';
    }
    if (key == 'enterOldPin') {
      if (locale == 'hr') return 'Unesite stari PIN';
      if (locale == 'de') return 'Alten PIN eingeben';
      return 'Enter current PIN';
    }
    return '';
  }

  String get _title {
    if (widget.isChanging) {
      if (_step == 0) return _t('enterOldPin');
      if (_step == 1) return _t('enterPin');
      return _t('confirmPin');
    }
    return _step == 0 ? _t('enterPin') : _t('confirmPin');
  }

  List<String> get _displayDigits => _digits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _displayDigits.length
                      ? AppTheme.accent(context)
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildNumpad(theme),
        ],
      ),
    );
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 64, height: 64);
              if (key == 'back') {
                return _NumBtn(
                  icon: Icons.backspace_outlined,
                  onPressed: _onBackspace,
                );
              }
              return _NumBtn(label: key, onPressed: () => _onDigit(key));
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _NumBtn({this.label, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: label != null
                  ? Text(label!, style: Theme.of(context).textTheme.titleLarge)
                  : Icon(icon, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
