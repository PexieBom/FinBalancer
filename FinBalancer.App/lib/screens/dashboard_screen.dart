import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;

import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../utils/currency_formatter.dart';
import '../l10n/app_localizations.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../providers/app_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/dashboard_settings_provider.dart';
import '../providers/linked_account_provider.dart';
import '../providers/notifications_provider.dart';
import '../models/wallet_budget.dart';
import '../models/category.dart' as app_models;
import '../models/achievement.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/notifications_icon.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = context.read<LocaleProvider>().localeCode;
      context.read<DataProvider>().loadAll(locale: locale);
      context.read<SubscriptionProvider>().loadStatus(
            context.read<AppProvider>().user?.id,
          );
      context.read<LinkedAccountProvider>().loadLinks();
      context.read<NotificationsProvider>().loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _showCustomizeDashboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Consumer<DashboardSettingsProvider>(
          builder: (ctx2, settings, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.customizeDashboard, style: Theme.of(ctx2).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    _CustomizeSwitch(label: l10n.showPlan, value: settings.showPlan, onChanged: settings.setShowPlan),
                    _CustomizeSwitch(label: l10n.showGoals, value: settings.showGoals, onChanged: settings.setShowGoals),
                    _CustomizeSwitch(label: l10n.showAchievements, value: settings.showAchievements, onChanged: settings.setShowAchievements),
                    _CustomizeSwitch(label: l10n.showBudget, value: settings.showBudget, onChanged: settings.setShowBudget),
                    _CustomizeSwitch(label: l10n.showStatistics, value: settings.showStatistics, onChanged: settings.setShowStatistics),
                    _CustomizeSwitch(label: l10n.showExpensesChart, value: settings.showExpensesChart, onChanged: settings.setShowExpensesChart),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                  ],
                ),
              ),
            );
          },
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

  Widget _buildAccountSwitcher(BuildContext context, DataProvider dataProvider, String localeCode) {
    return Consumer<LinkedAccountProvider>(
      builder: (context, linkProvider, _) {
        if (linkProvider.linkedHosts.isEmpty) return const SizedBox.shrink();
        final theme = Theme.of(context);
        final isMyAccount = dataProvider.viewAsHostId == null || dataProvider.viewAsHostId!.isEmpty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(Localizations.localeOf(context).languageCode == 'hr' ? 'Moj račun' : 'My account'),
                  selected: isMyAccount,
                  onSelected: (_) {
                    dataProvider.setViewAsHostId(null);
                    dataProvider.loadAll(locale: localeCode);
                  },
                ),
                const SizedBox(width: 8),
                ...linkProvider.linkedHosts.map((host) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(host.displayName),
                    selected: dataProvider.viewAsHostId == host.hostUserId,
                    onSelected: (_) {
                      dataProvider.setViewAsHostId(host.hostUserId);
                      dataProvider.loadAll(locale: localeCode);
                    },
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  app_models.TransactionCategory? _getCategory(DataProvider provider, String id) {
    try {
      return provider.categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildPlanCard(BuildContext context, LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<SubscriptionProvider>(
        builder: (context, subProvider, _) {
          if (subProvider.isPremium) {
            final productId = subProvider.status.productId ?? '';
            final planName = productId.contains('yearly')
                ? l10n.premiumYearly
                : l10n.premiumMonthly;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.plan,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          planName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return InkWell(
            onTap: () => Navigator.pushNamed(context, '/premium-features')
                .then((_) => context.read<SubscriptionProvider>().loadStatus(
                      context.read<AppProvider>().user?.id,
                    )),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black54
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.plan,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          l10n.freePlan,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.upgradeToPremium,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.accent(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.accent(context)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    DataProvider provider,
    intl.NumberFormat fmt,
    AppLocalizations l10n, {
    String? walletName,
    BudgetCurrent? budget,
  }) {
    final name = walletName ?? provider.dashboardBudgetWalletName ?? l10n.allWallets;
    final b = budget ?? provider.dashboardBudget;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/wallets', arguments: 1).then((_) => provider.loadAll()),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: b == null
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.accent(context).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.pie_chart_outline, color: AppTheme.accent(context), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.budget,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n.setBudget,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                )
              : _buildBudgetCardContent(context, b, name, fmt, l10n),
        ),
      ),
    );
  }

  Widget _buildBudgetCardContent(BuildContext context, BudgetCurrent budget, String walletName, intl.NumberFormat fmt, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accent(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.pie_chart_outline, color: AppTheme.accent(context), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${l10n.budget} · $walletName',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _PaceChip(paceStatus: budget.paceStatus, l10n: l10n),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BudgetLabelValue(label: l10n.budget, value: fmt.format(budget.budgetAmount)),
            _BudgetLabelValue(label: l10n.spent, value: fmt.format(budget.spent), valueColor: AppTheme.expense(context)),
            _BudgetLabelValue(
              label: l10n.remaining,
              value: fmt.format(budget.remaining),
              valueColor: budget.remaining >= 0 ? AppTheme.income(context) : AppTheme.expense(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.period}: ${intl.DateFormat('dd.MM.yyyy').format(budget.periodStart)} – ${intl.DateFormat('dd.MM.yyyy').format(budget.periodEnd)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.allowancePerDay}: ${fmt.format(budget.allowancePerDay)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (budget.explanation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            budget.explanation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            l10n.wallets,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.accent(context),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection(BuildContext context, DataProvider provider, intl.NumberFormat fmt, AppLocalizations l10n) {
    final budgets = provider.dashboardBudgets;
    if (budgets.isEmpty) {
      return _buildBudgetCard(context, provider, fmt, l10n);
    }
    if (budgets.length == 1) {
      final name = budgets.first.walletName == 'All Wallets' ? l10n.allWallets : budgets.first.walletName;
      return _buildBudgetCard(context, provider, fmt, l10n, walletName: name, budget: budgets.first.budget);
    }
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: budgets.length,
        itemBuilder: (_, i) {
          final item = budgets[i];
          final name = item.walletName == 'All Wallets' ? l10n.allWallets : item.walletName;
          return _buildBudgetCard(context, provider, fmt, l10n, walletName: name, budget: item.budget);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      activeNavIndex: 0,
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
          Consumer<SubscriptionProvider>(
            builder: (context, sub, _) => sub.isPremium
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                      message: 'Premium Active',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.black87),
                            const SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                : const SizedBox.shrink(),
          ),
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
          const NotificationsIcon(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final locale = context.read<LocaleProvider>().localeCode;
              context.read<DataProvider>().loadAll(locale: locale);
              context.read<SubscriptionProvider>().loadStatus(
                    context.read<AppProvider>().user?.id,
                  );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              final dp = context.read<DataProvider>();
              final locale = context.read<LocaleProvider>().localeCode;
              if (v == 'categories') Navigator.pushNamed(context, '/categories').then((_) => dp.loadAll(locale: locale));
              if (v == 'achievements') Navigator.pushNamed(context, '/achievements-list').then((_) => dp.loadAll(locale: locale));
              if (v == 'export') _showExportMenu(context);
              if (v == 'settings') Navigator.pushNamed(context, '/settings');
              if (v == 'premium') Navigator.pushNamed(context, '/premium-features');
              if (v == 'customize') _showCustomizeDashboard(context);
            },
            itemBuilder: (_) {
              final l10n = AppLocalizations.of(context)!;
              final isPremium = context.read<SubscriptionProvider>().isPremium;
              final iconColor = Theme.of(context).colorScheme.onSurface;
              return [
                PopupMenuItem(value: 'categories', child: Row(children: [Icon(Icons.category, size: 22, color: iconColor), const SizedBox(width: 12), Text(l10n.categories)])),
                PopupMenuItem(value: 'achievements', child: Row(children: [Icon(Icons.emoji_events, size: 22, color: iconColor), const SizedBox(width: 12), Text(l10n.achievements)])),
                PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.upload_file, size: 22, color: iconColor), const SizedBox(width: 12), Text(l10n.exportData)])),
                PopupMenuItem(value: 'premium', child: Row(children: [Icon(Icons.star, size: 22, color: isPremium ? Colors.amber : iconColor), const SizedBox(width: 12), Text(l10n.premiumFeatures)])),
                PopupMenuItem(value: 'customize', child: Row(children: [Icon(Icons.dashboard_customize, size: 22, color: iconColor), const SizedBox(width: 12), Text(l10n.customizeDashboard)])),
                PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings, size: 22, color: iconColor), const SizedBox(width: 12), Text(l10n.settings)])),
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<DataProvider>().clearUserData();
              await context.read<AppProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Consumer3<DataProvider, LocaleProvider, DashboardSettingsProvider>(
        builder: (context, provider, localeProvider, dashSettings, _) {
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
            onRefresh: () async {
              await provider.loadAll(locale: localeProvider.localeCode);
              await context.read<SubscriptionProvider>().loadStatus(
                    context.read<AppProvider>().user?.id,
                  );
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildAccountSwitcher(context, provider, localeProvider.localeCode),
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
                              value: provider.filterWalletId,
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
                              onChanged: (v) async {
                                provider.setFilter(walletId: v);
                                await provider.loadTransactions();
                              },
                            ),
                          ),
                        BalanceCard(
                          title: () {
                            if (provider.filterWalletId == null) return l10n.allWallets;
                            final w = provider.wallets.where((x) => x.id == provider.filterWalletId).toList();
                            return w.isEmpty ? l10n.allWallets : w.first.name;
                          }(),
                          amount: () {
                            if (provider.filterWalletId == null) return provider.totalBalance;
                            final w = provider.wallets.where((x) => x.id == provider.filterWalletId).toList();
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
                  const SizedBox(height: 16),
                  if (dashSettings.showPlan) _buildPlanCard(context, localeProvider),
                  if (dashSettings.showPlan) const SizedBox(height: 24),
                  if (dashSettings.showBudget) _buildBudgetSection(context, provider, fmt, l10n),
                  if (dashSettings.showBudget) const SizedBox(height: 24),
                  if (dashSettings.showGoals)
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
                  if (dashSettings.showGoals) const SizedBox(height: 12),
                  if (dashSettings.showAchievements && provider.achievements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/achievements-list').then((_) => provider.loadAll(locale: localeProvider.localeCode)),
                        borderRadius: BorderRadius.circular(16),
                        child: _AchievementsRow(achievements: provider.achievements, l10n: l10n),
                      ),
                    ),
                  if (dashSettings.showAchievements && provider.achievements.isNotEmpty) const SizedBox(height: 24),
                  if (dashSettings.showStatistics)
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
                  if (dashSettings.showExpensesChart && provider.getExpensesByCategory().isNotEmpty) ...[
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          ).then((_) {}),
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
                              ).then((_) {}),
                              child: Text(l10n.addTransaction),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...provider.recentTransactions.map(
                      (t) => TransactionTile(
                        transaction: t,
                        category: _getCategory(provider, t.categoryId),
                        onEdit: () => Navigator.pushNamed(
                          context,
                          '/add-transaction',
                          arguments: t,
                        ).then((_) {}),
                        onDelete: () => provider.deleteTransaction(t.id),
                        currencyFormat: fmt,
                      ),
                    ),
                    if (provider.hasMoreTransactions)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: () => provider.loadMoreDisplayedTransactions(),
                            child: Text(l10n.loadMore),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
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
    final chartSize = 180.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40; // horizontal padding

    return SizedBox(
      width: availableWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: availableWidth,
            height: chartSize,
            child: PieChart(
            PieChartData(
              sections: spots.asMap().entries.map((e) {
                final total = data.values.fold(0.0, (a, b) => a + b);
                final value = total > 0 ? (e.value.value / total * 100) : 0.0;
                return PieChartSectionData(
                  value: value,
                  title: '${value.toStringAsFixed(0)}%',
                  color: colors[e.key % colors.length],
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: availableWidth,
          child: Wrap(
            spacing: 10,
            runSpacing: 6,
            children: spots.asMap().entries.map((e) {
              final color = colors[e.key % colors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(
                    e.value.key,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
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

class _PaceChip extends StatelessWidget {
  final String paceStatus;
  final AppLocalizations l10n;

  const _PaceChip({required this.paceStatus, required this.l10n});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (paceStatus) {
      case 'OnTrack':
        label = l10n.onTrack;
        color = AppTheme.income(context);
        break;
      case 'OverPace':
        label = l10n.overPace;
        color = AppTheme.expense(context);
        break;
      case 'UnderPace':
        label = l10n.underPace;
        color = Colors.orange;
        break;
      default:
        label = paceStatus;
        color = Theme.of(context).colorScheme.onSurface;
    }
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withValues(alpha: 0.15),
    );
  }
}

class _BudgetLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BudgetLabelValue({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _CustomizeSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _CustomizeSwitch({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (v) => onChanged(v),
    );
  }
}

