import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';
import '../models/category.dart' as app_models;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _nameController = TextEditingController();
  bool _showAddForm = false;
  String _addType = 'expense';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadCategories(locale: context.read<LocaleProvider>().localeCode);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCustomCategory(DataProvider provider) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _error = null);
    try {
      await provider.addCustomCategory(name, _addType);
      _nameController.clear();
      setState(() => _showAddForm = false);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
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
          'Categories',
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
          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categories are loaded from the API',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          final incomeCategories =
              provider.categories.where((c) => c.type == 'income').toList();
          final expenseCategories =
              provider.categories.where((c) => c.type == 'expense').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showAddForm) _buildAddForm(context, provider),
                if (_showAddForm) const SizedBox(height: 24),
                if (!_showAddForm)
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showAddForm = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add custom category'),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.accent(context))),
                    ),
                  ),
                if (!_showAddForm) const SizedBox(height: 24),
                _buildSection(context, provider, 'Income', incomeCategories, AppTheme.income(context)),
                const SizedBox(height: 24),
                _buildSection(context, provider, 'Expense', expenseCategories, AppTheme.expense(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddForm(BuildContext context, DataProvider provider) {
    return Container(
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
          Text('New custom category', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
              ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
            ],
            selected: {_addType},
            onSelectionChanged: (s) => setState(() => _addType = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: AppTheme.expense(context))),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() { _showAddForm = false; _error = null; _nameController.clear(); }), child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () => _addCustomCategory(provider), child: const Text('Add'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, DataProvider provider, String title,
      List<app_models.TransactionCategory> categories, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 12),
        ...categories.map((c) => _CategoryTile(
              category: c,
              color: color,
              onDelete: c.icon == 'custom' ? () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete category?'),
                    content: Text('Remove "${c.name}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: AppTheme.expense(context)))),
                    ],
                  ),
                );
                if (ok == true) await provider.deleteCustomCategory(c.id);
              } : null,
            )),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final app_models.TransactionCategory category;
  final Color color;
  final VoidCallback? onDelete;

  const _CategoryTile({required this.category, required this.color, this.onDelete});

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

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(category.icon), color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          if (onDelete != null)
            IconButton(icon: Icon(Icons.delete, color: AppTheme.expense(context)), onPressed: onDelete),
        ],
      ),
    );
  }
}
