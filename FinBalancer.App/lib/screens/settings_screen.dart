import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notifications_icon.dart';
import '../providers/locale_provider.dart';
import '../providers/data_provider.dart';
import '../providers/app_lock_provider.dart';
import '../l10n/app_localizations.dart';
import 'set_pin_sheet.dart';

// Languages with full ARB translations
final _supportedLocales = [
  ('en', 'English'),
  ('hr', 'Hrvatski'),
  ('de', 'Deutsch'),
  ('fr', 'Français'),
  ('es', 'Español'),
  ('it', 'Italiano'),
  ('pt', 'Português'),
  ('nl', 'Nederlands'),
];

const _currencies = [
  ('EUR', '€ Euro'),
  ('USD', '\$ US Dollar'),
  ('GBP', '£ British Pound'),
  ('HRK', 'kn Kuna'),
  ('CHF', 'CHF Swiss Franc'),
  ('PLN', 'zł Polish Złoty'),
  ('CZK', 'Kč Czech Koruna'),
  ('HUF', 'Ft Hungarian Forint'),
  ('RON', 'lei Romanian Leu'),
  ('BGN', 'лв Bulgarian Lev'),
  ('RUB', '₽ Russian Ruble'),
  ('TRY', '₺ Turkish Lira'),
  ('JPY', '¥ Japanese Yen'),
  ('CNY', '¥ Chinese Yuan'),
  ('KRW', '₩ South Korean Won'),
  ('INR', '₹ Indian Rupee'),
  ('BRL', 'R\$ Brazilian Real'),
  ('MXN', '\$ Mexican Peso'),
  ('CAD', 'C\$ Canadian Dollar'),
  ('AUD', 'A\$ Australian Dollar'),
  ('SEK', 'kr Swedish Krona'),
  ('NOK', 'kr Norwegian Krone'),
  ('DKK', 'kr Danish Krone'),
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppLockProvider>(
      builder: (context, lock, _) => Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.settings,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [NotificationsIcon()],
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: _linkedAccountsTitle(context)),
                const SizedBox(height: 8),
                _buildLinkedAccountsTile(context),
                const SizedBox(height: 24),
                _SectionHeader(title: _themeSectionTitle(context)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.light_mode, color: Theme.of(context).colorScheme.primary),
                        title: Text(_themeLight(context)),
                        trailing: provider.themeMode == ThemeMode.light ? Icon(Icons.check, color: AppTheme.accent(context)) : null,
                        onTap: () => provider.setThemeMode(ThemeMode.light),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                        title: Text(_themeDark(context)),
                        trailing: provider.themeMode == ThemeMode.dark ? Icon(Icons.check, color: AppTheme.accent(context)) : null,
                        onTap: () => provider.setThemeMode(ThemeMode.dark),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.brightness_auto, color: Theme.of(context).colorScheme.primary),
                        title: Text(_themeSystem(context)),
                        trailing: provider.themeMode == ThemeMode.system ? Icon(Icons.check, color: AppTheme.accent(context)) : null,
                        onTap: () => provider.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ),
                if (lock.isMobile) ...[
                  _SectionHeader(title: _appLockTitle(context)),
                  const SizedBox(height: 8),
                  _buildAppLockSection(context, lock),
                  const SizedBox(height: 24),
                ],
                _SectionHeader(title: l10n.language),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.localeCode,
                      isExpanded: true,
                      items: _supportedLocales.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                      onChanged: (code) async {
                        if (code == null) return;
                        await provider.setLocale(Locale(code));
                        if (context.mounted) context.read<DataProvider>().loadCategories(locale: code);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: l10n.currency),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.currency,
                      isExpanded: true,
                      items: _currencies.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                      onChanged: (code) {
                        if (code != null) provider.setCurrency(code);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildLinkedAccountsTile(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.people_outline, color: theme.colorScheme.primary),
        title: Text(_linkedAccountsTitle(context)),
        subtitle: Text(_linkedAccountsSubtitle(context)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, '/linked-accounts'),
      ),
    );
  }

  Widget _buildAppLockSection(BuildContext context, AppLockProvider lock) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (lock.isEnabled) ...[
            ListTile(
              leading: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
              title: Text(_changePinText(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSetPinSheet(context, isChanging: true),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.lock_open, color: theme.colorScheme.primary),
              title: Text(_disablePinText(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDisablePinDialog(context, lock),
            ),
          ] else ...[
            ListTile(
              leading: Icon(Icons.lock, color: theme.colorScheme.primary),
              title: Text(_enablePinText(context)),
              subtitle: Text(_enablePinSubtitle(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSetPinSheet(context, isChanging: false),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSetPinSheet(BuildContext context, {required bool isChanging}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SetPinSheet(isChanging: isChanging),
      ),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_pinSavedText(context))),
      );
    }
  }

  Future<void> _showDisablePinDialog(BuildContext context, AppLockProvider lock) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_disablePinTitle(ctx)),
        content: Text(_disablePinMessage(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_disablePinConfirm(ctx)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await lock.removePin();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_pinDisabledText(context))),
        );
      }
    }
  }
}

String _appLockTitle(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Zaključavanje aplikacije';
    case 'de': return 'App-Sperre';
    case 'fr': return "Verrouillage de l'app";
    case 'es': return 'Bloqueo de app';
    case 'it': return 'Blocco app';
    default: return 'App Lock';
  }
}

String _enablePinText(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Omogući PIN za ulazak';
    case 'de': return 'PIN aktivieren';
    case 'fr': return 'Activer le code';
    case 'es': return 'Activar PIN';
    case 'it': return 'Attiva PIN';
    default: return 'Enable PIN';
  }
}

String _enablePinSubtitle(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Zaštitite pristup aplikaciji';
    case 'de': return 'App-Zugriff schützen';
    case 'fr': return "Protéger l'accès à l'app";
    default: return 'Protect app access';
  }
}

String _changePinText(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Promijeni PIN';
    case 'de': return 'PIN ändern';
    case 'fr': return 'Changer le code';
    default: return 'Change PIN';
  }
}

String _disablePinText(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Onemogući zaključavanje';
    case 'de': return 'Sperre deaktivieren';
    case 'fr': return 'Désactiver le verrouillage';
    default: return 'Disable lock';
  }
}

String _disablePinTitle(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Onemogućiti PIN?';
    case 'de': return 'PIN deaktivieren?';
    default: return 'Disable PIN?';
  }
}

String _disablePinMessage(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Aplikacija više neće tražiti PIN pri pokretanju.';
    case 'de': return 'Die App fordert beim Start keinen PIN mehr an.';
    default: return 'The app will no longer ask for a PIN when opening.';
  }
}

String _disablePinConfirm(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Onemogući';
    case 'de': return 'Deaktivieren';
    default: return 'Disable';
  }
}

String _pinSavedText(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'PIN spremljen';
    case 'de': return 'PIN gespeichert';
    default: return 'PIN saved';
  }
}

String _pinDisabledText(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Zaključavanje onemogućeno';
    case 'de': return 'Sperre deaktiviert';
    default: return 'Lock disabled';
  }
}

String _linkedAccountsTitle(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Povezani računi';
    case 'de': return 'Verbundene Konten';
    default: return 'Linked accounts';
  }
}

String _linkedAccountsSubtitle(BuildContext context) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hr': return 'Pozovi druge da vide tvoje podatke';
    case 'de': return 'Andere einladen, deine Daten zu sehen';
    default: return 'Invite others to view your data';
  }
}

String _themeSectionTitle(BuildContext context) {
  switch (AppLocalizations.of(context)?.localeName ?? 'en') {
    case 'hr': return 'Tema';
    case 'de': return 'Design';
    case 'fr': return 'Thème';
    case 'es': return 'Tema';
    case 'it': return 'Tema';
    case 'pt': return 'Tema';
    case 'nl': return 'Thema';
    default: return 'Theme';
  }
}

String _themeLight(BuildContext context) {
  switch (AppLocalizations.of(context)?.localeName ?? 'en') {
    case 'hr': return 'Svjetlo';
    case 'de': return 'Hell';
    case 'fr': return 'Clair';
    case 'es': return 'Claro';
    case 'it': return 'Chiaro';
    case 'pt': return 'Claro';
    case 'nl': return 'Licht';
    default: return 'Light';
  }
}

String _themeDark(BuildContext context) {
  switch (AppLocalizations.of(context)?.localeName ?? 'en') {
    case 'hr': return 'Tamno';
    case 'de': return 'Dunkel';
    case 'fr': return 'Sombre';
    case 'es': return 'Oscuro';
    case 'it': return 'Scuro';
    case 'pt': return 'Escuro';
    case 'nl': return 'Donker';
    default: return 'Dark';
  }
}

String _themeSystem(BuildContext context) {
  switch (AppLocalizations.of(context)?.localeName ?? 'en') {
    case 'hr': return 'Sustav';
    case 'de': return 'System';
    case 'fr': return 'Système';
    case 'es': return 'Sistema';
    case 'it': return 'Sistema';
    case 'pt': return 'Sistema';
    case 'nl': return 'Systeem';
    default: return 'System';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
