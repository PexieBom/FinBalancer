import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart' as app_models;
import '../utils/currency_formatter.dart';
import '../widgets/main_bottom_nav.dart';
import '../l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? editingTransaction;

  const AddTransactionScreen({super.key, this.editingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  bool _isIncome = false;
  final List<String> _tags = [];
  String? _selectedSubcategoryId;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  bool _isYearlyExpense = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final editing = widget.editingTransaction;
    if (editing != null) {
      _amountController.text = editing.amount.toStringAsFixed(2).replaceAll('.', ',');
      _noteController.text = editing.note ?? '';
      _isIncome = editing.type == 'income';
      _selectedCategoryId = editing.categoryId;
      _selectedSubcategoryId = editing.subcategoryId;
      _selectedWalletId = editing.walletId;
      _tags.addAll(editing.tags);
      _isYearlyExpense = editing.isYearlyExpense;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ne pozivamo loadAll - resetirao bi displayedTransactionCount i scroll na dashboardu.
      // Dashboard je već učitao podatke; dodajemo samo subcategories ako treba.
      if (editing != null && _selectedCategoryId != null) {
        context.read<DataProvider>().loadSubcategories(categoryId: _selectedCategoryId!);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DataProvider>();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'))!;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final editing = widget.editingTransaction;
      final transaction = Transaction(
        id: editing?.id ?? '',
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        dateCreated: editing?.dateCreated ?? DateTime.now(),
        tags: List.from(_tags),
        subcategoryId: _selectedSubcategoryId,
        project: null,
        projectId: null,
        isYearlyExpense: _isYearlyExpense,
      );
      if (editing != null) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
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
          widget.editingTransaction != null
              ? AppLocalizations.of(context)!.editTransaction
              : AppLocalizations.of(context)!.addTransactionTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories
              .where((c) => c.type == (_isIncome ? 'income' : 'expense'))
              .toList();
          final wallets = provider.wallets;
          final main = provider.mainWallet;
          if (_selectedWalletId == null && main != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedWalletId = main.id);
            });
          }

          if (wallets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.addWalletFirst,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.needWalletFirst,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/wallets'),
                      child: Text(AppLocalizations.of(context)!.addWallet),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cardShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                value: false,
                                label: Text(AppLocalizations.of(context)!.expenseLabel),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text(AppLocalizations.of(context)!.incomeLabel),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                            selected: {_isIncome},
                            onSelectionChanged: (value) {
                              setState(() {
                                _isIncome = value.first;
                                _selectedCategoryId = null;
                                _selectedSubcategoryId = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.amount,
                            prefixText: '€ ',
                          ),
                          validator: (v) {
                            final l10n = AppLocalizations.of(context)!;
                            if (v == null || v.isEmpty) return l10n.required;
                            final n = double.tryParse(v.replaceAll(',', '.'));
                            if (n == null || n <= 0) return l10n.enterValidAmount;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                          validator: (v) => v == null ? AppLocalizations.of(context)!.pleaseSelectCategory : null,
                          items: categories
                              .map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Icon(_getIcon(c.icon), size: 20),
                                        const SizedBox(width: 8),
                                        Text(c.name),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedCategoryId = v;
                              _selectedSubcategoryId = null;
                              if (v != null) {
                                provider.loadSubcategories(categoryId: v);
                              }
                            });
                          },
                        ),
                        if (_selectedCategoryId != null) ...[
                          const SizedBox(height: 16),
                          Consumer<DataProvider>(
                            builder: (context, prov, _) {
                              final subcats = prov.subcategories.toList();
                              if (subcats.isEmpty) return const SizedBox.shrink();
                              return DropdownButtonFormField<String>(
                                value: _selectedSubcategoryId,
                                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.subcategoryOptional),
                                items: [
                                  DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.none)),
                                  ...subcats.map((s) => DropdownMenuItem(
                                        value: s.id,
                                        child: Text(s.name),
                                      )),
                                ],
                                onChanged: (v) => setState(() => _selectedSubcategoryId = v),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedWalletId,
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.wallet),
                          validator: (v) => v == null ? AppLocalizations.of(context)!.pleaseSelectWallet : null,
                          items: wallets
                              .map((w) => DropdownMenuItem(
                                    value: w.id,
                                    child: Text(
                                        '${w.name} (${formatCurrency(w.balance, context.read<LocaleProvider>())})'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedWalletId = v),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.noteOptional),
                          maxLines: 2,
                        ),
                        if (!_isIncome) ...[
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(AppLocalizations.of(context)!.yearlyExpenseFlag),
                            subtitle: Text(AppLocalizations.of(context)!.yearlyExpenseFlagHint),
                            value: _isYearlyExpense,
                            onChanged: (v) => setState(() => _isYearlyExpense = v),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _TagsInput(
                          tagsOptional: AppLocalizations.of(context)!.tagsOptional,
                          tagHint: AppLocalizations.of(context)!.tagHint,
                          tags: _tags,
                          tagController: _tagController,
                          onAdd: (tag) {
                            if (tag.isNotEmpty && !_tags.contains(tag)) {
                              setState(() => _tags.add(tag));
                              _tagController.clear();
                            }
                          },
                          onRemove: (tag) => setState(() => _tags.remove(tag)),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.expense(context).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppTheme.expense(context)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_error!)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isIncome
                            ? AppTheme.income(context)
                            : AppTheme.accent(context),
                        foregroundColor: Colors.white,
                      ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(AppLocalizations.of(context)!.saveTransaction),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const MainBottomNav(activeIndex: 1),
    );
  }

  IconData _getIcon(String name) {
    const icons = {
      'restaurant': Icons.restaurant,
      'restaurant_menu': Icons.restaurant_menu,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'category': Icons.category,
      'account_balance_wallet': Icons.account_balance_wallet,
      'star': Icons.star,
      'attach_money': Icons.attach_money,
      'custom': Icons.bookmark,
      'credit_card': Icons.credit_card,
      'handshake': Icons.handshake,
      'build': Icons.build,
      'home_repair_service': Icons.home_repair_service,
      'bolt': Icons.bolt,
      'local_gas_station': Icons.local_gas_station,
      'subscriptions': Icons.subscriptions,
      'health_and_safety': Icons.health_and_safety,
    };
    return icons[name] ?? Icons.receipt;
  }
}

class _TagsInput extends StatelessWidget {
  final String tagsOptional;
  final String tagHint;
  final List<String> tags;
  final TextEditingController tagController;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _TagsInput({
    required this.tagsOptional,
    required this.tagHint,
    required this.tags,
    required this.tagController,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tagsOptional, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => onRemove(tag),
                )),
            SizedBox(
              width: 120,
              child: TextField(
                controller: tagController,
                decoration: InputDecoration(
                  hintText: tagHint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: onAdd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
