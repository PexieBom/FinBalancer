import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../models/wallet.dart';
import '../l10n/app_localizations.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _currencyController = TextEditingController(text: 'EUR');
  bool _showAddForm = false;
  bool _isLoading = false;
  String? _error;
  Wallet? _editingWallet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadWallets();
    });
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Wallets',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showAddForm) ...[
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
                          _editingWallet != null ? AppLocalizations.of(context)!.editWallet : AppLocalizations.of(context)!.newWallet,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.nameLabel,
                            hintText: AppLocalizations.of(context)!.walletNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _balanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.initialBalance,
                            prefixText: '€ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _currencyController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.currency,
                            hintText: AppLocalizations.of(context)!.currencyHint,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(color: AppTheme.expense(context)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => setState(() {
                                          _showAddForm = false;
                                          _error = null;
                                          _editingWallet = null;
                                          _nameController.clear();
                                          _balanceController.clear();
                                          _currencyController.clear();
                                        }),
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () async { if (_editingWallet != null) await _saveWallet(provider); else await _addWallet(); },
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(_editingWallet != null ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
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
                      onPressed: () => setState(() => _showAddForm = true),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!.addWallet),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.accent(context)),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (provider.wallets.isEmpty && !_showAddForm)
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
                          'No wallets yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first wallet to get started',
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
                        onEdit: () => _editWallet(context, provider, w),
                        onDelete: () => _deleteWallet(context, provider, w),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WalletCard({required this.wallet, required this.onEdit, required this.onDelete});

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
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: Icon(Icons.delete, color: AppTheme.expense(context)), onPressed: onDelete),
        ],
      ),
    );
  }
}
