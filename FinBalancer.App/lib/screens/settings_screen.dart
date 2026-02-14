import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../providers/data_provider.dart';
import '../l10n/app_localizations.dart';

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
    return Scaffold(
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: l10n.language),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black54
                            : AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _supportedLocales.map((e) {
                      final code = e.$1;
                      final name = e.$2;
                      final isSelected = provider.localeCode == code;
                      return ListTile(
                        title: Text(name),
                        trailing: isSelected ? Icon(Icons.check, color: AppTheme.accent(context)) : null,
                        onTap: () async {
                          await provider.setLocale(Locale(code));
                          if (context.mounted) {
                            context.read<DataProvider>().loadCategories(locale: code);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: _themeSectionTitle(context)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black54
                            : AppTheme.cardShadow,
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
                        trailing: provider.themeMode == ThemeMode.light
                            ? Icon(Icons.check, color: AppTheme.accent(context))
                            : null,
                        onTap: () => provider.setThemeMode(ThemeMode.light),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                        title: Text(_themeDark(context)),
                        trailing: provider.themeMode == ThemeMode.dark
                            ? Icon(Icons.check, color: AppTheme.accent(context))
                            : null,
                        onTap: () => provider.setThemeMode(ThemeMode.dark),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.brightness_auto, color: Theme.of(context).colorScheme.primary),
                        title: Text(_themeSystem(context)),
                        trailing: provider.themeMode == ThemeMode.system
                            ? Icon(Icons.check, color: AppTheme.accent(context))
                            : null,
                        onTap: () => provider.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: l10n.currency),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black54
                            : AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _currencies.map((e) {
                      final code = e.$1;
                      final label = e.$2;
                      final isSelected = provider.currency == code;
                      return ListTile(
                        title: Text(label),
                        trailing: isSelected ? Icon(Icons.check, color: AppTheme.accent(context)) : null,
                        onTap: () => provider.setCurrency(code),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
