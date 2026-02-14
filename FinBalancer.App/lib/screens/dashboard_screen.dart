import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../utils/currency_formatter.dart';
import '../l10n/app_localizations.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../providers/app_provider.dart';
import '../models/category.dart' as app_models;
import '../models/achievement.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = context.read<LocaleProvider>().localeCode;
      context.read<DataProvider>().loadAll(locale: locale);
    });
  }

  void _showExportMenu(BuildContext context) {
    final api = ApiService();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(context)!.exportData, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: Text(AppLocalizations.of(context)!.csv),
                onTap: () => _launchExport(ctx, api.getExportUrl('csv')),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(AppLocalizations.of(context)!.json),
                onTap: () => _launchExport(ctx, api.getExportUrl('json')),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(AppLocalizations.of(context)!.pdfHtml),
                onTap: () => _launchExport(ctx, api.getExportUrl('pdf')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExport(BuildContext sheetContext, String url) async {
    Navigator.pop(sheetContext);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  app_models.TransactionCategory? _getCategory(DataProvider provider, String id) {
    try {
      return provider.categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.dashboard,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Consumer<LocaleProvider>(
            builder: (context, locale, _) => IconButton(
              icon: Icon(
                locale.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => locale.setThemeMode(
                locale.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              final dp = context.read<DataProvider>();
              final locale = context.read<LocaleProvider>().localeCode;
              if (v == 'categories') Navigator.pushNamed(context, '/categories').then((_) => dp.loadAll(locale: locale));
              if (v == 'projects') Navigator.pushNamed(context, '/projects').then((_) => dp.loadAll(locale: locale));
              if (v == 'achievements') Navigator.pushNamed(context, '/achievements-list').then((_) => dp.loadAll(locale: locale));
              if (v == 'export') _showExportMenu(context);
              if (v == 'settings') Navigator.pushNamed(context, '/settings');
              if (v == 'premium') Navigator.pushNamed(context, '/premium-features');
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'categories', child: Text(AppLocalizations.of(context)!.categories)),
              PopupMenuItem(value: 'projects', child: const Text('Projects')),
              PopupMenuItem(value: 'achievements', child: Text(AppLocalizations.of(context)!.achievements)),
              PopupMenuItem(value: 'export', child: Text(AppLocalizations.of(context)!.exportData)),
              PopupMenuItem(value: 'premium', child: Text(AppLocalizations.of(context)!.premiumFeatures)),
              PopupMenuItem(value: 'settings', child: Text(AppLocalizations.of(context)!.settings)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AppProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Consumer2<DataProvider, LocaleProvider>(
        builder: (context, provider, localeProvider, _) {
          final l10n = AppLocalizations.of(context)!;
          final fmt = currencyNumberFormat(localeProvider);
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.wallets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      l10n.cannotConnectApi,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.ensureBackendRunning,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.loadAll(locale: localeProvider.localeCode),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAll(locale: localeProvider.localeCode),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'FinBalancer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.totalBalance,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.wallets.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: DropdownButtonFormField<String?>(
                              value: _selectedWalletId,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                filled: true,
                                fillColor: Theme.of(context).cardTheme.color,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(l10n.allWallets),
                                ),
                                ...provider.wallets.map((w) => DropdownMenuItem(
                                      value: w.id,
                                      child: Text(w.name),
                                    )),
                              ],
                              onChanged: (v) => setState(() => _selectedWalletId = v),
                            ),
                          ),
                        BalanceCard(
                          title: () {
                            if (_selectedWalletId == null) return l10n.allWallets;
                            final w = provider.wallets.where((x) => x.id == _selectedWalletId).toList();
                            return w.isEmpty ? l10n.allWallets : w.first.name;
                          }(),
                          amount: () {
                            if (_selectedWalletId == null) return provider.totalBalance;
                            final w = provider.wallets.where((x) => x.id == _selectedWalletId).toList();
                            return w.isEmpty ? provider.totalBalance : w.first.balance;
                          }(),
                          currencyFormat: fmt,
                          icon: Icons.account_balance_wallet,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: BalanceCard(
                            title: l10n.income,
                            amount: provider.totalIncome,
                            currencyFormat: fmt,
                            color: AppTheme.income(context),
                            icon: Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BalanceCard(
                            title: l10n.expense,
                            amount: provider.totalExpense,
                            currencyFormat: fmt,
                            color: AppTheme.expense(context),
                            icon: Icons.trending_down,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/goals')
                          .then((_) => provider.loadAll(locale: localeProvider.localeCode)),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black54
                                  : AppTheme.cardShadow,
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.income(context).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.flag, color: AppTheme.income(context), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.goals,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    l10n.goalsSubtitle(provider.goals.length),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.achievements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/achievements-list').then((_) => provider.loadAll(locale: localeProvider.localeCode)),
                        borderRadius: BorderRadius.circular(16),
                        child: _AchievementsRow(achievements: provider.achievements, l10n: l10n),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/statistics'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black54
                                  : AppTheme.cardShadow,
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.accent(context).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.bar_chart_rounded, color: AppTheme.accent(context), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.statistics,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    l10n.statisticsSubtitle,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (provider.getExpensesByCategory().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.expensesByCategory,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildPieChart(context, provider),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recentTransactions,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/add-transaction',
                          ).then((_) => provider.loadAll()),
                          child: Text(l10n.addTransaction),
                        ),
                      ],
                    ),
                  ),
                  if (provider.recentTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noTransactionsYet,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/add-transaction',
                              ).then((_) => provider.loadAll()),
                              child: Text(l10n.addTransaction),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...provider.recentTransactions.map(
                      (t) => TransactionTile(
                        transaction: t,
                        category: _getCategory(provider, t.categoryId),
                        onDelete: () => provider.deleteTransaction(t.id),
                        currencyFormat: fmt,
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildPieChart(BuildContext context, DataProvider provider) {
    final data = provider.getExpensesByCategory();
    if (data.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppTheme.expense(context),
      AppTheme.accent(context),
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    final spots = data.entries.toList();
    return PieChart(
      PieChartData(
        sections: spots.asMap().entries.map((e) {
          final total = data.values.fold(0.0, (a, b) => a + b);
          final value = total > 0 ? (e.value.value / total * 100) : 0.0;
          return PieChartSectionData(
            value: value,
            title: '${value.toStringAsFixed(0)}%',
            color: colors[e.key % colors.length],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard, label: l10n.home, isActive: true),
              _NavItem(
                icon: Icons.add_circle_outline,
                label: l10n.add,
                onTap: () => Navigator.pushNamed(context, '/add-transaction')
                    .then((_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode)),
              ),
              _NavItem(
                icon: Icons.bar_chart,
                label: l10n.stats,
                onTap: () => Navigator.pushNamed(context, '/statistics'),
              ),
              _NavItem(
                icon: Icons.flag,
                label: l10n.goals,
                onTap: () => Navigator.pushNamed(context, '/goals')
                    .then((_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode)),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet,
                label: l10n.wallets,
                onTap: () => Navigator.pushNamed(context, '/wallets')
                    .then((_) => context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  final List<Achievement> achievements;
  final AppLocalizations l10n;

  const _AchievementsRow({required this.achievements, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    if (unlocked.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? Colors.amber.shade900.withOpacity(0.4) : Colors.amber.shade50;
    final badgeBorder = isDark ? Colors.amber.shade600 : Colors.amber.shade200;
    final iconColor = isDark ? Colors.amber.shade400 : Colors.amber.shade700;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.achievements,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: unlocked.take(5).map((a) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: iconColor, size: 18),
                      const SizedBox(width: 6),
                      Text(a.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.accent(context) : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? AppTheme.accent(context) : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
