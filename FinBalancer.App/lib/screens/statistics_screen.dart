import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/notifications_icon.dart';
import '../services/api_service.dart';
import '../providers/subscription_provider.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ApiService _api = ApiService();
  bool _predictionExpanded = false;
  bool _categoriesExpanded = false;
  Map<String, dynamic>? _spendingData;
  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _budgetPrediction;
  List<dynamic> _budgetAlerts = [];
  Map<String, dynamic>? _cashflowTrend;
  bool _isLoading = true;
  String? _error;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  int _months = 6;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadUnreadCount();
    });
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    if (!mounted) return;
    final viewAsHostId = context.read<DataProvider>().viewAsHostId;
    try {
      final results = await Future.wait([
        _api.getSpendingByCategory(dateFrom: _dateFrom, dateTo: _dateTo, viewAsHostId: viewAsHostId),
        _api.getIncomeExpenseSummary(dateFrom: _dateFrom, dateTo: _dateTo, viewAsHostId: viewAsHostId),
        _api.getBudgetPrediction(viewAsHostId: viewAsHostId),
        _api.getBudgetAlerts(viewAsHostId: viewAsHostId),
        _api.getCashflowTrend(months: _months, dateFrom: _dateFrom, dateTo: _dateTo, viewAsHostId: viewAsHostId),
      ]);
      setState(() {
        _spendingData = results[0] as Map<String, dynamic>;
        _summaryData = results[1] as Map<String, dynamic>;
        _budgetPrediction = results[2] as Map<String, dynamic>;
        _budgetAlerts = results[3] as List<dynamic>;
        _cashflowTrend = results[4] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      activeNavIndex: 3,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const NotificationsIcon(),
          Tooltip(
            message: 'Filter period',
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showDateRangePicker(context),
            ),
          ),
          Tooltip(
            message: 'Date range',
            child: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _showDateRangePicker(context),
            ),
          ),
          Tooltip(
            message: 'Export data',
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _showExportSheet(context),
            ),
          ),
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ),
        ],
      ),
      body: Consumer2<SubscriptionProvider, DataProvider>(
        builder: (context, sub, dataProvider, _) {
          final hasStatsAccess = sub.isPremium || dataProvider.isViewingAsGuest;
          if (!hasStatsAccess) {
            return _buildPremiumPlaceholder(context);
          }
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_summaryData != null) _buildSummaryCards(),
                        if (_summaryData != null) ...[
                          const SizedBox(height: 24),
                          _buildMonthlyChart(),
                        ],
        if (_budgetAlerts.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildBudgetAlerts(),
        ],
                        if (_budgetPrediction != null) ...[
                          const SizedBox(height: 24),
                          _buildBudgetPrediction(),
                        ],
                        if (_cashflowTrend != null) ...[
                          const SizedBox(height: 24),
                          _buildCashflowTrendChart(),
                        ],
                        if (_spendingData != null) ...[
                          const SizedBox(height: 24),
                          _buildSpendingByCategory(),
                        ],
                        const SizedBox(height: 40),
                        if (_summaryData == null && _spendingData == null && _budgetPrediction == null)
                          const Center(child: Text('No data available')),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Export data', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                onTap: () => _launchExport(ctx, _api.getExportUrl('csv')),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON'),
                onTap: () => _launchExport(ctx, _api.getExportUrl('json')),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF (HTML)'),
                onTap: () => _launchExport(ctx, _api.getExportUrl('pdf')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text('Period', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Select time range for statistics', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Last 1 month'),
                    selected: _months == 1 && _dateFrom == null,
                    onSelected: (_) { setState(() { _months = 1; _dateFrom = null; _dateTo = null; }); Navigator.pop(ctx); _loadData(); },
                  ),
                  ChoiceChip(
                    label: const Text('Last 3 months'),
                    selected: _months == 3 && _dateFrom == null,
                    onSelected: (_) { setState(() { _months = 3; _dateFrom = null; _dateTo = null; }); Navigator.pop(ctx); _loadData(); },
                  ),
                  ChoiceChip(
                    label: const Text('Last 6 months'),
                    selected: _months == 6 && _dateFrom == null,
                    onSelected: (_) { setState(() { _months = 6; _dateFrom = null; _dateTo = null; }); Navigator.pop(ctx); _loadData(); },
                  ),
                  ChoiceChip(
                    label: const Text('Last 12 months'),
                    selected: _months == 12 && _dateFrom == null,
                    onSelected: (_) { setState(() { _months = 12; _dateFrom = null; _dateTo = null; }); Navigator.pop(ctx); _loadData(); },
                  ),
                  ChoiceChip(
                    label: const Text('This year'),
                    selected: _dateFrom != null && _dateFrom!.month == 1 && _dateFrom!.day == 1,
                    onSelected: (_) {
                      final now = DateTime.now();
                      setState(() { _dateFrom = DateTime(now.year, 1, 1); _dateTo = now; _months = 12; });
                      Navigator.pop(ctx);
                      _loadData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Custom range'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _dateFrom != null && _dateTo != null
                        ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
                        : DateTimeRange(start: DateTime.now().subtract(const Duration(days: 180)), end: DateTime.now()),
                  );
                  if (range != null) {
                    setState(() { _dateFrom = range.start; _dateTo = range.end; });
                    _loadData();
                  }
                },
              ),
              if (_dateFrom != null || _months != 6)
                TextButton(
                  onPressed: () { setState(() { _dateFrom = null; _dateTo = null; _months = 6; }); Navigator.pop(ctx); _loadData(); },
                  child: const Text('Reset to default'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryTransactions(BuildContext context, String categoryId, String categoryName) async {
    DateTime? from = _dateFrom;
    DateTime? to = _dateTo;
    if (from == null && to == null && _months > 0) {
      final now = DateTime.now();
      to = now;
      from = DateTime(now.year, now.month - _months, now.day);
    }
    final viewAsHostId = context.read<DataProvider>().viewAsHostId;
    try {
      final txList = await _api.getTransactions(categoryId: categoryId, dateFrom: from, dateTo: to, viewAsHostId: viewAsHostId);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('$categoryName (${txList.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: txList.isEmpty
                ? const Text('No transactions in this period')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: txList.length,
                    itemBuilder: (_, i) {
                      final t = txList[i];
                      final fmt = NumberFormat.currency(locale: 'hr_HR', symbol: '€');
                      return ListTile(
                        title: Text(t.note ?? DateFormat('dd.MM.yyyy').format(t.dateCreated)),
                        trailing: Text('${t.type == 'income' ? '+' : '-'}${fmt.format(t.amount)}', style: TextStyle(color: t.type == 'income' ? AppTheme.income(ctx) : AppTheme.expense(ctx), fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    }
  }

  Future<void> _launchExport(BuildContext sheetContext, String url) async {
    Navigator.pop(sheetContext);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPremiumPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to Premium to view your statistics, charts, and insights.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/premium-features'),
              icon: const Icon(Icons.star),
              label: const Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Failed to load statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _summaryData!;
    final income = (summary['totalIncome'] as num?)?.toDouble() ?? 0.0;
    final expense = (summary['totalExpense'] as num?)?.toDouble() ?? 0.0;
    final balance = (summary['balance'] as num?)?.toDouble() ?? 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');

    final savingsRate = income > 0 ? ((income - expense) / income * 100) : 0.0;
    int expenseTxCount = 0;
    if (_spendingData != null) {
      final byCat = _spendingData!['byCategory'] as List<dynamic>? ?? [];
      for (final c in byCat) {
        expenseTxCount += (c as Map<String, dynamic>)['count'] as int? ?? 0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Income',
                amount: income,
                color: AppTheme.income(context),
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Expense',
                amount: expense,
                color: AppTheme.expense(context),
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: 'Balance',
          amount: balance,
          color: balance >= 0 ? AppTheme.income(context) : AppTheme.expense(context),
          icon: Icons.account_balance_wallet,
        ),
        if (income > 0 || expenseTxCount > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (income > 0)
                Expanded(
                  child: _SummaryCard(
                    title: 'Savings rate',
                    amount: savingsRate,
                    color: savingsRate >= 0 ? AppTheme.income(context) : AppTheme.expense(context),
                    icon: Icons.savings,
                    isPercent: true,
                  ),
                ),
              if (income > 0 && expenseTxCount > 0) const SizedBox(width: 12),
              if (expenseTxCount > 0)
                Expanded(
                  child: _SummaryCard(
                    title: 'Expense transactions',
                    amount: expenseTxCount.toDouble(),
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.receipt_long,
                    isCount: true,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Alerts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...(_budgetAlerts).map((a) {
          final alert = a as Map<String, dynamic>;
          final msg = alert['message'] as String? ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.expense(context).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.expense(context).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.expense(context)),
                const SizedBox(width: 12),
                Expanded(child: Text(msg, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBudgetPrediction() {
    final pred = _budgetPrediction!;
    final byCategory = pred['byCategory'] as List<dynamic>? ?? [];
    final total = (pred['totalPredictedNextMonth'] as num?)?.toDouble() ?? 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');

    if (byCategory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Predicted Spending (Next Month)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Based on your last 3 months average +5%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _predictionExpanded = !_predictionExpanded),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total predicted', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text(currencyFormat.format(total), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.accent(context))),
                        const SizedBox(width: 8),
                        Icon(_predictionExpanded ? Icons.expand_less : Icons.expand_more),
                      ],
                    ),
                  ],
                ),
              ),
              if (_predictionExpanded) ...[
                const Divider(),
                ...byCategory.map((c) {
                  final cat = c as Map<String, dynamic>;
                  final name = cat['categoryName'] as String? ?? '';
                  final predicted = (cat['predictedNextMonth'] as num?)?.toDouble() ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        Text(currencyFormat.format(predicted), style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashflowTrendChart() {
    final points = _cashflowTrend!['points'] as List<dynamic>? ?? [];
    if (points.isEmpty) return const SizedBox.shrink();

    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');

    double maxVal = 0;
    for (final p in points) {
      final pt = p as Map<String, dynamic>;
      final inc = (pt['income'] as num?)?.toDouble() ?? 0.0;
      final exp = (pt['expense'] as num?)?.toDouble() ?? 0.0;
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }
    final maxY = maxVal > 0 ? maxVal * 1.15 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Income vs Expense by Month', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Monthly totals', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chartLegend(context, AppTheme.income(context), 'Income'),
            const SizedBox(width: 16),
            _chartLegend(context, AppTheme.expense(context), 'Expense'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: points.asMap().entries.map((e) {
                final pt = e.value as Map<String, dynamic>;
                final income = (pt['income'] as num?)?.toDouble() ?? 0.0;
                final expense = (pt['expense'] as num?)?.toDouble() ?? 0.0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: AppTheme.income(context),
                      width: 14,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: expense,
                      color: AppTheme.expense(context),
                      width: 14,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                  barsSpace: 4,
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (v, meta) => Text(
                      currencyFormat.format(v),
                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= points.length) return const SizedBox();
                      final pt = points[i] as Map<String, dynamic>;
                      final month = pt['month'] as int? ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${monthNames[month]}', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline))),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Theme.of(context).colorScheme.surfaceContainerHighest,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final pt = points[group.x] as Map<String, dynamic>;
                    final income = (pt['income'] as num?)?.toDouble() ?? 0.0;
                    final expense = (pt['expense'] as num?)?.toDouble() ?? 0.0;
                    final label = rodIndex == 0 ? 'Income' : 'Expense';
                    final val = rodIndex == 0 ? income : expense;
                    return BarTooltipItem(
                      '$label: ${currencyFormat.format(val)}',
                      TextStyle(color: rodIndex == 0 ? AppTheme.income(context) : AppTheme.expense(context), fontWeight: FontWeight.w600, fontSize: 12),
                    );
                  },
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chartLegend(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildSpendingByCategory() {
    final spending = _spendingData!;
    final byCategory = spending['byCategory'] as List<dynamic>? ?? [];
    if (byCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            Text('Spending by Category', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            Icon(Icons.pie_chart_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text('No expense data yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final totalExpense = (spending['totalExpense'] as num?)?.toDouble() ?? 1.0;
    final colors = [AppTheme.expense(context), AppTheme.accent(context), Colors.orange, Colors.purple, Colors.teal, Colors.amber];
    final displayCount = _categoriesExpanded ? byCategory.length : byCategory.length.clamp(0, 6);
    final displayedCategories = byCategory.take(displayCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spending by Category', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Tap a category to see transactions', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (byCategory.length > 6)
              TextButton.icon(
                icon: Icon(_categoriesExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
                label: Text(_categoriesExpanded ? 'Show less' : 'Show all (${byCategory.length})'),
                onPressed: () => setState(() => _categoriesExpanded = !_categoriesExpanded),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: displayedCategories.asMap().entries.map((e) {
                final cat = e.value as Map<String, dynamic>;
                final value = (cat['total'] as num?)?.toDouble() ?? 0.0;
                final pct = totalExpense > 0 ? (value / totalExpense * 100) : 0.0;
                return PieChartSectionData(
                  value: pct,
                  title: '${pct.toStringAsFixed(0)}%',
                  color: colors[e.key % colors.length],
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: displayedCategories.asMap().entries.map((e) {
            final cat = e.value as Map<String, dynamic>;
            final name = cat['categoryName'] as String? ?? 'Unknown';
            final color = colors[e.key % colors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(name, style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ...displayedCategories.map((c) {
          final cat = c as Map<String, dynamic>;
          final catId = cat['categoryId']?.toString();
          final name = cat['categoryName'] as String? ?? 'Unknown';
          final total = (cat['total'] as num?)?.toDouble() ?? 0.0;
          final pct = totalExpense > 0 ? (total / totalExpense * 100) : 0.0;
          return InkWell(
            onTap: catId != null ? () => _showCategoryTransactions(context, catId, name) : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface))),
                  Text(NumberFormat.currency(locale: 'hr_HR', symbol: '€').format(total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.expense(context),
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(width: 8),
                  Text('${pct.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    final byMonth = _summaryData!['byMonth'] as List<dynamic>? ?? [];
    if (byMonth.isEmpty) return const SizedBox.shrink();

    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Income and expense per month', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        ...byMonth.take(6).map((e) {
          final m = e as Map<String, dynamic>;
          final income = (m['income'] as num?)?.toDouble() ?? 0.0;
          final expense = (m['expense'] as num?)?.toDouble() ?? 0.0;
          final month = m['month'] as int? ?? 0;
          final year = m['year'] as int? ?? 0;
          final diff = income - expense;
          final diffStr = diff >= 0 ? '+${currencyFormat.format(diff)}' : currencyFormat.format(diff);
          final label = '${monthNames[month]} $year';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Income: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    Text(currencyFormat.format(income), style: TextStyle(color: AppTheme.income(context), fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expense: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    Text(currencyFormat.format(expense), style: TextStyle(color: AppTheme.expense(context), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Difference: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    Text(diffStr, style: TextStyle(color: diff >= 0 ? AppTheme.income(context) : AppTheme.expense(context), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isPercent;
  final bool isCount;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.isPercent = false,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');
    final displayText = isPercent
        ? '${amount.toStringAsFixed(1)}%'
        : isCount
            ? amount.toInt().toString()
            : currencyFormat.format(amount);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(displayText, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
