import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart' as app_models;
import '../utils/currency_formatter.dart';
import '../l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();
  final _projectController = TextEditingController();

  bool _isIncome = false;
  final List<String> _tags = [];
  String? _selectedSubcategoryId;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  String? _selectedProjectId;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAll(locale: context.read<LocaleProvider>().localeCode);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DataProvider>();
    if (_selectedWalletId == null) {
      setState(() => _error = AppLocalizations.of(context)!.pleaseSelectWallet);
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _error = AppLocalizations.of(context)!.pleaseSelectCategory);
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = AppLocalizations.of(context)!.pleaseEnterValidAmount);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transaction = Transaction(
        id: '',
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        dateCreated: DateTime.now(),
        tags: List.from(_tags),
        subcategoryId: _selectedSubcategoryId,
        project: _projectController.text.trim().isEmpty ? null : _projectController.text.trim(),
        projectId: _selectedProjectId,
      );
      await provider.addTransaction(transaction);
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
          AppLocalizations.of(context)!.addTransactionTitle,
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
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Expense'),
                                icon: Icon(Icons.remove_circle_outline),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('Income'),
                                icon: Icon(Icons.add_circle_outline),
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
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '€ ',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = double.tryParse(v.replaceAll(',', '.'));
                            if (n == null || n <= 0) return 'Enter valid amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'Category'),
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
                                decoration: const InputDecoration(labelText: 'Subcategory (optional)'),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('— None —')),
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
                          decoration: const InputDecoration(labelText: 'Wallet'),
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
                          decoration: const InputDecoration(labelText: 'Note (optional)'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Consumer<DataProvider>(
                          builder: (context, prov, _) {
                            final projects = prov.projects;
                            return DropdownButtonFormField<String?>(
                              value: _selectedProjectId,
                              decoration: const InputDecoration(
                                labelText: 'Project (optional)',
                                hintText: '— None —',
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('— None —')),
                                ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                              ],
                              onChanged: (v) => setState(() => _selectedProjectId = v),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/projects').then((_) => provider.loadAll(locale: context.read<LocaleProvider>().localeCode)),
                          icon: const Icon(Icons.add),
                          label: const Text('Manage projects'),
                        ),
                        const SizedBox(height: 16),
                        _TagsInput(
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
                          : const Text('Save Transaction'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String name) {
    const icons = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'category': Icons.category,
      'account_balance_wallet': Icons.account_balance_wallet,
      'star': Icons.star,
      'attach_money': Icons.attach_money,
      'custom': Icons.bookmark,
    };
    return icons[name] ?? Icons.receipt;
  }
}

class _TagsInput extends StatelessWidget {
  final List<String> tags;
  final TextEditingController tagController;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _TagsInput({
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
        const Text('Tags (optional)', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                decoration: const InputDecoration(
                  hintText: '+ tag',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
