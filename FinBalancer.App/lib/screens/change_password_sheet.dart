import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      setState(() => _error = _changePasswordCurrentRequired(context));
      return;
    }
    if (newPass.length < 6) {
      setState(() => _error = _changePasswordMinLength(context));
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = _changePasswordMismatch(context));
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    final err = await context.read<AppProvider>().changePassword(current, newPass);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _changePasswordTitle(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _currentController,
            obscureText: _obscureCurrent,
            decoration: InputDecoration(
              labelText: _changePasswordCurrent(context),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newController,
            obscureText: _obscureNew,
            decoration: InputDecoration(
              labelText: _changePasswordNew(context),
              suffixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: _changePasswordConfirm(context),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: AppTheme.expense(context))),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)?.save ?? 'Save'),
          ),
        ],
      ),
    );
  }
}

String _changePasswordTitle(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Promjena lozinke';
    case 'de': return 'Passwort ändern';
    case 'fr': return 'Changer le mot de passe';
    case 'es': return 'Cambiar contraseña';
    default: return 'Change password';
  }
}

String _changePasswordCurrent(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Trenutna lozinka';
    case 'de': return 'Aktuelles Passwort';
    default: return 'Current password';
  }
}

String _changePasswordNew(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Nova lozinka';
    case 'de': return 'Neues Passwort';
    default: return 'New password';
  }
}

String _changePasswordConfirm(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Potvrdi novu lozinku';
    case 'de': return 'Neues Passwort bestätigen';
    default: return 'Confirm new password';
  }
}

String _changePasswordCurrentRequired(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Unesite trenutnu lozinku';
    default: return 'Enter current password';
  }
}

String _changePasswordMinLength(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Nova lozinka mora imati najmanje 6 znakova';
    default: return 'New password must be at least 6 characters';
  }
}

String _changePasswordMismatch(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Lozinke se ne podudaraju';
    default: return 'Passwords do not match';
  }
}
