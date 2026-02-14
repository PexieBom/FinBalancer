import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _spendingData;
  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _budgetPrediction;
  List<dynamic> _budgetAlerts = [];
  Map<String, dynamic>? _cashflowTrend;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.getSpendingByCategory(),
        _api.getIncomeExpenseSummary(),
        _api.getBudgetPrediction(),
        _api.getBudgetAlerts(),
        _api.getCashflowTrend(),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
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
                        if (_summaryData != null) ...[
                          const SizedBox(height: 24),
                          _buildMonthlyChart(),
                        ],
                        const SizedBox(height: 40),
                        if (_summaryData == null && _spendingData == null && _budgetPrediction == null)
                          const Center(child: Text('No data available')),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard, label: 'Home', onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
              _NavItem(icon: Icons.add_circle_outline, label: 'Add', onTap: () => Navigator.pushReplacementNamed(context, '/add-transaction')),
              _NavItem(icon: Icons.bar_chart, label: 'Stats', isActive: true),
              _NavItem(icon: Icons.account_balance_wallet, label: 'Wallets', onTap: () => Navigator.pushReplacementNamed(context, '/wallets')),
              _NavItem(icon: Icons.category, label: 'Categories', onTap: () => Navigator.pushReplacementNamed(context, '/categories')),
            ],
          ),
        ),
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

  Future<void> _launchExport(BuildContext sheetContext, String url) async {
    Navigator.pop(sheetContext);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
        Text('Based on your last 3 months average +5%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              ...byCategory.map((c) {
                final cat = c as Map<String, dynamic>;
                final name = cat['categoryName'] as String? ?? '';
                final predicted = (cat['predictedNextMonth'] as num?)?.toDouble() ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name),
                      Text(currencyFormat.format(predicted), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total predicted', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(currencyFormat.format(total), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.accent(context))),
                ],
              ),
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

    final netValues = points.map((p) {
      final pt = p as Map<String, dynamic>;
      return (pt['net'] as num?)?.toDouble() ?? 0.0;
    }).toList();
    final maxNet = netValues.map((v) => v.abs()).fold(0.0, (a, b) => a > b ? a : b);
    final minY = maxNet > 0 ? -maxNet * 1.1 : -100.0;
    final maxY = maxNet > 0 ? maxNet * 1.1 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cashflow Trend', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Income vs expense by month', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: minY,
              barGroups: points.asMap().entries.map((e) {
                final pt = e.value as Map<String, dynamic>;
                final net = (pt['net'] as num?)?.toDouble() ?? 0.0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: net,
                      color: net >= 0 ? AppTheme.income(context) : AppTheme.expense(context),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      final year = pt['year'] as int? ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${monthNames[month]}', style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.grey.shade800,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final pt = points[group.x] as Map<String, dynamic>;
                    final net = (pt['net'] as num?)?.toDouble() ?? 0.0;
                    return BarTooltipItem('Net: ${currencyFormat.format(net)}', const TextStyle(color: Colors.white, fontSize: 12));
                  },
                ),
              ),
            ),
          ),
        ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text('Spending by Category', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No expense data yet', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    final totalExpense = (spending['totalExpense'] as num?)?.toDouble() ?? 1.0;
    final colors = [AppTheme.expense(context), AppTheme.accent(context), Colors.orange, Colors.purple, Colors.teal, Colors.amber];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spending by Category', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: byCategory.asMap().entries.take(6).map((e) {
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
        const SizedBox(height: 16),
        ...byCategory.map((c) {
          final cat = c as Map<String, dynamic>;
          final name = cat['categoryName'] as String? ?? 'Unknown';
          final total = (cat['total'] as num?)?.toDouble() ?? 0.0;
          final pct = totalExpense > 0 ? (total / totalExpense * 100) : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(child: Text(name, style: Theme.of(context).textTheme.titleMedium)),
                Text(NumberFormat.currency(locale: 'hr_HR', symbol: '€').format(total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.expense(context),
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(width: 8),
                Text('${pct.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
              ],
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
        const SizedBox(height: 16),
        ...byMonth.take(6).map((e) {
          final m = e as Map<String, dynamic>;
          final income = (m['income'] as num?)?.toDouble() ?? 0.0;
          final expense = (m['expense'] as num?)?.toDouble() ?? 0.0;
          final month = m['month'] as int? ?? 0;
          final year = m['year'] as int? ?? 0;
          final label = '${monthNames[month]} $year';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Income: ', style: Theme.of(context).textTheme.bodyMedium),
                    Text(currencyFormat.format(income), style: TextStyle(color: AppTheme.income(context), fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expense: ', style: Theme.of(context).textTheme.bodyMedium),
                    Text(currencyFormat.format(expense), style: TextStyle(color: AppTheme.expense(context), fontWeight: FontWeight.w600)),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({required this.icon, required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppTheme.accent(context) : Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? AppTheme.accent(context) : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({required this.title, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');
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
          Text(currencyFormat.format(amount), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
