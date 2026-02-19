import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';

/// Jedinstveni donji navigacijski izbornik za sve glavne stranice.
/// activeIndex: 0=Home, 1=Add, 2=Stats, 3=DecisionEngine, 4=Wallets. -1 = none active.
class MainBottomNav extends StatelessWidget {
  final int activeIndex;

  const MainBottomNav({super.key, this.activeIndex = -1});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.dashboard,
                label: l10n.home,
                isActive: activeIndex == 0,
                onTap: () => _navigate(context, '/dashboard'),
              ),
              _NavItem(
                icon: Icons.add_circle_outline,
                label: l10n.add,
                isActive: activeIndex == 1,
                onTap: () => Navigator.pushNamed(context, '/add-transaction')
                    .then((_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode)),
              ),
              _NavItem(
                icon: Icons.bar_chart,
                label: l10n.stats,
                isActive: activeIndex == 2,
                onTap: () => _navigate(context, '/statistics'),
              ),
              _NavItem(
                icon: Icons.psychology,
                label: l10n.decisionEngine,
                isActive: activeIndex == 3,
                onTap: () => _navigate(context, '/decision-engine'),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet,
                label: l10n.walletsBudgets,
                isActive: activeIndex == 4,
                onTap: () => Navigator.pushNamed(context, '/wallets')
                    .then((_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (route == '/dashboard') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.accent(context) : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive ? AppTheme.accent(context) : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 9,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
