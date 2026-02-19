import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/main_bottom_nav.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';
import '../l10n/app_localizations.dart';
import '../models/category.dart' as app_models;

class DecisionEngineScreen extends StatefulWidget {
  const DecisionEngineScreen({super.key});

  @override
  State<DecisionEngineScreen> createState() => _DecisionEngineScreenState();
}

class _DecisionEngineScreenState extends State<DecisionEngineScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategoryId;
  double? _monthlyIncome;
  bool _hasEvaluated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode);
      _loadMonthlyIncome();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthlyIncome() async {
    try {
      final api = ApiService();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final summary = await api.getIncomeExpenseSummary(dateFrom: startOfMonth, dateTo: endOfMonth);
      if (summary != null && summary['totalIncome'] != null) {
        setState(() => _monthlyIncome = (summary['totalIncome'] as num).toDouble());
      }
    } catch (_) {
      setState(() => _monthlyIncome = 0);
    }
  }

  (int score, Color color) _evaluate(double amount, double monthlyIncome) {
    if (monthlyIncome <= 0) return (5, Colors.grey);
    final pct = (amount / monthlyIncome) * 100;
    int score;
    Color color;
    if (pct <= 5) {
      score = 9;
      color = Colors.green;
    } else if (pct <= 10) {
      score = 7;
      color = Colors.lightGreen;
    } else if (pct <= 20) {
      score = 5;
      color = Colors.blue;
    } else if (pct <= 35) {
      score = 3;
      color = Colors.amber;
    } else {
      score = 1;
      color = Colors.red;
    }
    return (score, color);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.decisionEngine,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories.where((c) => c.type == 'expense').toList();
          final monthlyIncome = _monthlyIncome ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.decisionEngineSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixText: '€ ',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(labelText: l10n.category),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: l10n.decisionEngineDescription),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      setState(() { _error = l10n.enterValidAmount; _hasEvaluated = false; });
                      return;
                    }
                    setState(() { _error = null; _hasEvaluated = true; });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent(context),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.evaluate),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: AppTheme.expense(context))),
                ],
                const SizedBox(height: 32),
                Builder(
                  builder: (context) {
                    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
                    if (amount == null || amount <= 0 || !_hasEvaluated) return const SizedBox.shrink();
                    final (score, color) = _evaluate(amount, monthlyIncome);
                    final pct = monthlyIncome > 0 ? (amount / monthlyIncome * 100) : 0.0;
                    final fmt = NumberFormat.currency(locale: 'hr_HR', symbol: '€');
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.decisionEngineResult, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${l10n.decisionEnginePercentOfIncome}:'),
                              Text('${pct.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${l10n.decisionEngineScore}:'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
                                child: Text('$score/10', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const MainBottomNav(activeIndex: 3),
    );
  }
}
