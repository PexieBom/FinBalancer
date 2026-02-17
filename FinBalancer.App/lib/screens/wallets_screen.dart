import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../models/wallet.dart';
import '../models/wallet_budget.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../providers/subscription_provider.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _currencyController = TextEditingController(text: 'EUR');
  bool _showAddForm = false;
  bool _isLoading = false;
  String? _error;
  Wallet? _editingWallet;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DataProvider>();
      provider.loadWallets();
      provider.loadBudgets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _addWallet() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter wallet name');
      return;
    }

    final balance = double.tryParse(_balanceController.text.replaceAll(',', '.'));
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<DataProvider>().addWallet(
            Wallet(
              id: '',
              name: name,
              balance: balance ?? 0,
              currency: _currencyController.text.trim().isNotEmpty
                  ? _currencyController.text.trim()
                  : 'EUR',
            ),
          );
      _nameController.clear();
      _balanceController.clear();
      setState(() {
        _showAddForm = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _editWallet(BuildContext context, DataProvider provider, Wallet w) {
    _editingWallet = w;
    _nameController.text = w.name;
    _balanceController.text = w.balance.toString();
    _currencyController.text = w.currency;
    setState(() => _showAddForm = true);
  }

  Future<void> _deleteWallet(BuildContext context, DataProvider provider, Wallet w) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteWalletQuestion),
        content: Text('${AppLocalizations.of(context)!.removeWalletQuestion(w.name)} ${AppLocalizations.of(context)!.transactionsMayBeAffected}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: AppTheme.expense(context)))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await provider.deleteWallet(w.id);
      } catch (e) {
        if (context.mounted) setState(() => _error = e.toString());
      }
    }
  }

  Future<void> _saveWallet(DataProvider provider) async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      if (_editingWallet != null) {
        await provider.updateWallet(_editingWallet!.copyWith(
          name: _nameController.text.trim(),
          balance: double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? _editingWallet!.balance,
          currency: _currencyController.text.trim().isNotEmpty ? _currencyController.text.trim() : 'EUR',
        ));
      } else {
        await _addWallet();
        return;
      }
      _editingWallet = null;
      _nameController.clear();
      _balanceController.clear();
      _currencyController.clear();
      setState(() { _showAddForm = false; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
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
          l10n.wallets,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.wallets),
            Tab(text: l10n.budgets),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _WalletsTab(
            showAddForm: _showAddForm,
            isLoading: _isLoading,
            error: _error,
            editingWallet: _editingWallet,
            nameController: _nameController,
            balanceController: _balanceController,
            currencyController: _currencyController,
            onToggleAddForm: () => setState(() => _showAddForm = !_showAddForm),
            onAddWallet: _addWallet,
            onEditWallet: _editWallet,
            onDeleteWallet: _deleteWallet,
            onSaveWallet: _saveWallet,
            onClearForm: () => setState(() {
              _showAddForm = false;
              _error = null;
              _editingWallet = null;
              _nameController.clear();
              _balanceController.clear();
              _currencyController.clear();
            }),
          ),
          const _BudgetsTab(),
        ],
      ),
    );
  }
}

class _WalletsTab extends StatelessWidget {
  final bool showAddForm;
  final bool isLoading;
  final String? error;
  final Wallet? editingWallet;
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final TextEditingController currencyController;
  final VoidCallback onToggleAddForm;
  final Future<void> Function() onAddWallet;
  final void Function(BuildContext, DataProvider, Wallet) onEditWallet;
  final Future<void> Function(BuildContext, DataProvider, Wallet) onDeleteWallet;
  final Future<void> Function(DataProvider) onSaveWallet;
  final VoidCallback onClearForm;

  const _WalletsTab({
    required this.showAddForm,
    required this.isLoading,
    required this.error,
    required this.editingWallet,
    required this.nameController,
    required this.balanceController,
    required this.currencyController,
    required this.onToggleAddForm,
    required this.onAddWallet,
    required this.onEditWallet,
    required this.onDeleteWallet,
    required this.onSaveWallet,
    required this.onClearForm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<DataProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showAddForm) ...[
                  Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          editingWallet != null ? l10n.editWallet : l10n.newWallet,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: l10n.nameLabel,
                            hintText: l10n.walletNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: balanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.initialBalance,
                            prefixText: '€ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: currencyController,
                          decoration: InputDecoration(
                            labelText: l10n.currency,
                            hintText: l10n.currencyHint,
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            error!,
                            style: TextStyle(color: AppTheme.expense(context)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading ? null : onClearForm,
                                child: Text(l10n.cancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (editingWallet != null) {
                                          await onSaveWallet(provider);
                                        } else {
                                          await onAddWallet();
                                        }
                                      },
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(editingWallet != null ? l10n.save : l10n.add),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: onToggleAddForm,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addWallet),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.accent(context)),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (provider.wallets.isEmpty && !showAddForm)
                  Container(
                    padding: const EdgeInsets.all(40),
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
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.addWalletFirst,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.needWalletFirst,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...provider.wallets.map((w) => _WalletCard(
                        wallet: w,
                        onEdit: () => onEditWallet(context, provider, w),
                        onDelete: () => onDeleteWallet(context, provider, w),
                        onSetMain: w.isMain ? null : () => provider.setMainWallet(w.id),
                      )),
              ],
            ),
          );
        },
    );
  }
}

class _BudgetsTab extends StatelessWidget {
  const _BudgetsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');
    return Consumer<DataProvider>(
      builder: (context, provider, _) {
        if (provider.wallets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(l10n.noWalletsForBudget, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.loadBudgets(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _showBudgetEditSheet(context, provider),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addBudget),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.accent(context))),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBudgetRow(
                  context,
                  provider,
                  ApiService.globalBudgetId,
                  l10n.allWallets,
                  currencyFormat,
                  l10n,
                  null,
                ),
                ...provider.wallets.map((wallet) => _buildBudgetRow(
                      context,
                      provider,
                      wallet.id,
                      wallet.name,
                      currencyFormat,
                      l10n,
                      wallet,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetRow(
    BuildContext context,
    DataProvider provider,
    String budgetId,
    String displayName,
    NumberFormat currencyFormat,
    AppLocalizations l10n, [
    Wallet? wallet,
  ]) {
    BudgetSummary? summary;
    for (final b in provider.budgetSummaries) {
      if (b.walletId == budgetId) {
        summary = b;
        break;
      }
    }
    return summary != null
        ? _BudgetCard(
            walletName: displayName,
            budget: summary!.current,
            currencyFormat: currencyFormat,
            onEdit: () => _showBudgetEditSheet(context, provider, targetBudgetId: budgetId, targetName: displayName, wallet: wallet),
            onDelete: () => _deleteBudget(context, provider, budgetId, displayName, l10n),
          )
        : _SetBudgetCard(
            walletName: displayName,
            onSet: () => _showBudgetEditSheet(context, provider, targetBudgetId: budgetId, targetName: displayName, wallet: wallet),
            l10n: l10n,
          );
  }

  Future<void> _showBudgetEditSheet(
    BuildContext context,
    DataProvider provider, {
    String? targetBudgetId,
    String? targetName,
    Wallet? wallet,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final budgetAmountController = TextEditingController();
    final periodStartController = TextEditingController(text: '1');
    String? selectedWalletId = targetBudgetId ?? (provider.wallets.isNotEmpty ? provider.wallets.first.id : null);
    DateTime? selectedPeriodStartDate;
    DateTime? selectedPeriodEndDate;
    String? selectedCategoryId;
    BudgetCurrent? currentBudget;
    if (targetBudgetId != null) {
      try {
        final current = await provider.getWalletBudget(targetBudgetId);
        if (current != null) {
          currentBudget = current;
          budgetAmountController.text = current.budgetAmount.toStringAsFixed(0);
          periodStartController.text = current.periodStart.day.toString();
        }
      } catch (_) {}
    }
    if (selectedWalletId == null && provider.wallets.isNotEmpty) {
      selectedWalletId = ApiService.globalBudgetId;
    }

    if (!context.mounted) return;
    final isPremium = context.read<SubscriptionProvider>().isPremium;
    final expenseCategories = provider.categories.where((c) => c.type == 'expense').toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx2, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    targetBudgetId != null ? l10n.editBudget : l10n.addBudget,
                    style: Theme.of(ctx2).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  if (targetBudgetId == null)
                    DropdownButtonFormField<String>(
                      value: selectedWalletId,
                      decoration: InputDecoration(labelText: l10n.wallet),
                      items: [
                        DropdownMenuItem(value: ApiService.globalBudgetId, child: Text(l10n.allWallets)),
                        ...provider.wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))),
                      ],
                      onChanged: (v) => setModalState(() => selectedWalletId = v),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: Text(targetName ?? wallet?.name ?? l10n.allWallets),
                    ),
                  if (targetBudgetId != null && currentBudget != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.period}: ${DateFormat('dd.MM.yyyy').format(currentBudget!.periodStart)} – ${DateFormat('dd.MM.yyyy').format(currentBudget!.periodEnd)}',
                      style: Theme.of(ctx2).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(ctx2).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  if (targetBudgetId != null) const SizedBox(height: 16),
                  TextField(
                    controller: budgetAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.budgetAmount,
                      prefixText: '€ ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: periodStartController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.periodStartDay,
                      hintText: '1',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(selectedPeriodStartDate == null ? l10n.periodStartDate : DateFormat.yMd().format(selectedPeriodStartDate!)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedPeriodStartDate != null)
                          TextButton(
                            onPressed: () => setModalState(() {
                              selectedPeriodStartDate = null;
                              if (selectedPeriodEndDate != null) selectedPeriodEndDate = null;
                            }),
                            child: const Text('Clear'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx2,
                              initialDate: selectedPeriodStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) setModalState(() => selectedPeriodStartDate = picked);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(selectedPeriodEndDate == null ? l10n.periodEndDate : DateFormat.yMd().format(selectedPeriodEndDate!)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedPeriodEndDate != null)
                          TextButton(
                            onPressed: () => setModalState(() => selectedPeriodEndDate = null),
                            child: const Text('Clear'),
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final start = selectedPeriodStartDate ?? DateTime.now();
                            final picked = await showDatePicker(
                              context: ctx2,
                              initialDate: selectedPeriodEndDate ?? start.add(const Duration(days: 30)),
                              firstDate: start,
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) setModalState(() => selectedPeriodEndDate = picked);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(labelText: l10n.trackCategory),
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text(l10n.allCategories)),
                      ...expenseCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setModalState(() => selectedCategoryId = v),
                  ),
                  if (!isPremium) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: Colors.amber.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Budget management is a Premium feature. Upgrade to save.',
                              style: Theme.of(ctx2).textTheme.bodyMedium?.copyWith(color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isPremium ? () async {
                            final wid = selectedWalletId ?? targetBudgetId;
                            if (wid == null) return;
                            final amount = double.tryParse(budgetAmountController.text.replaceAll(',', '.'));
                            if (amount == null || amount <= 0) return;
                            final startDay = int.tryParse(periodStartController.text) ?? 1;
                            final clamped = startDay.clamp(1, 28);
                            try {
                              await provider.createOrUpdateBudget(
                                wid,
                                budgetAmount: amount,
                                periodStartDay: clamped,
                                periodStartDate: selectedPeriodStartDate,
                                periodEndDate: selectedPeriodEndDate,
                                categoryId: selectedCategoryId,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              if (ctx2.mounted) ScaffoldMessenger.of(ctx2).showSnackBar(SnackBar(content: Text('$e')));
                            }
                          } : null,
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    budgetAmountController.dispose();
    periodStartController.dispose();
  }

  Future<void> _deleteBudget(BuildContext context, DataProvider provider, String budgetId, String displayName, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBudgetQuestion),
        content: Text(l10n.removeWalletQuestion(displayName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: TextStyle(color: AppTheme.expense(context))),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await provider.deleteBudget(budgetId);
    }
  }
}

class _BudgetCard extends StatelessWidget {
  final String walletName;
  final BudgetCurrent budget;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.walletName,
    required this.budget,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String paceLabel;
    Color paceColor;
    switch (budget.paceStatus) {
      case 'OnTrack':
        paceLabel = l10n.onTrack;
        paceColor = AppTheme.income(context);
        break;
      case 'OverPace':
        paceLabel = l10n.overPace;
        paceColor = AppTheme.expense(context);
        break;
      case 'UnderPace':
        paceLabel = l10n.underPace;
        paceColor = Colors.orange;
        break;
      default:
        paceLabel = budget.paceStatus;
        paceColor = Theme.of(context).colorScheme.onSurface;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart_outline, color: AppTheme.accent(context), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  walletName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                label: Text(paceLabel, style: TextStyle(fontSize: 12, color: paceColor)),
                backgroundColor: paceColor.withOpacity(0.15),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              IconButton(icon: Icon(Icons.delete, color: AppTheme.expense(context)), onPressed: onDelete),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BudgetMetric(label: l10n.budget, value: currencyFormat.format(budget.budgetAmount)),
              _BudgetMetric(label: l10n.spent, value: currencyFormat.format(budget.spent), valueColor: AppTheme.expense(context)),
              _BudgetMetric(label: l10n.remaining, value: currencyFormat.format(budget.remaining), valueColor: budget.remaining >= 0 ? AppTheme.income(context) : AppTheme.expense(context)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.allowancePerDay}: ${currencyFormat.format(budget.allowancePerDay)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (budget.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              budget.explanation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BudgetMetric({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _SetBudgetCard extends StatelessWidget {
  final String walletName;
  final VoidCallback onSet;
  final AppLocalizations l10n;

  const _SetBudgetCard({required this.walletName, required this.onSet, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(walletName, style: Theme.of(context).textTheme.titleMedium),
                Text(l10n.setBudget, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onSet,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.setBudget),
            style: TextButton.styleFrom(foregroundColor: AppTheme.accent(context)),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetMain;

  const _WalletCard({required this.wallet, required this.onEdit, this.onDelete, this.onSetMain});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'hr_HR', symbol: '€');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accent(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: AppTheme.accent(context),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  wallet.currency,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(wallet.balance),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: wallet.balance >= 0
                      ? AppTheme.income(context)
                      : AppTheme.expense(context),
                ),
          ),
          IconButton(
            icon: Icon(wallet.isMain ? Icons.star : Icons.star_border, color: wallet.isMain ? Colors.amber : null),
            onPressed: onSetMain,
            tooltip: wallet.isMain ? 'Glavni novčanik' : 'Postavi kao glavni',
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: Icon(Icons.delete, color: AppTheme.expense(context)), onPressed: onDelete),
        ],
      ),
    );
  }
}
