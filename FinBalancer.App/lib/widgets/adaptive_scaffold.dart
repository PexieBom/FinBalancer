import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/responsive.dart';
import 'main_bottom_nav.dart';

/// Scaffold prilagođen za web: na širokim ekranima koristi NavigationRail umjesto bottom nav
/// i ograničava širinu sadržaja. Na mobilnim ostaje isti izgled.
class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int activeNavIndex; // -1 = nema aktivnog, 0=Home, 1=Add, 2=Stats, 3=DecisionEngine, 4=Wallets
  final Color? backgroundColor;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.activeNavIndex = -1,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    if (wide) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: Row(
          children: [
            _buildNavigationRail(context),
            Expanded(
              child: webAdaptiveContent(
                context,
                body,
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
      bottomNavigationBar: MainBottomNav(activeIndex: activeNavIndex),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationRail(
      extended: MediaQuery.sizeOf(context).width >= 900,
      backgroundColor: Theme.of(context).cardTheme.color,
      selectedIndex: activeNavIndex >= 0 ? activeNavIndex : 0,
      onDestinationSelected: (i) => _onNavTap(context, i),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppTheme.accent(context)),
          label: Text(l10n.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle, color: AppTheme.accent(context)),
          label: Text(l10n.add),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart, color: AppTheme.accent(context)),
          label: Text(l10n.stats),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology, color: AppTheme.accent(context)),
          label: Text(l10n.decisionEngine),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet, color: AppTheme.accent(context)),
          label: Text(l10n.walletsBudgets),
        ),
      ],
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/add-transaction').then(
          (_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/statistics');
        break;
      case 3:
        Navigator.pushNamed(context, '/decision-engine');
        break;
      case 4:
        Navigator.pushNamed(context, '/wallets').then(
          (_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode),
        );
        break;
    }
  }
}
