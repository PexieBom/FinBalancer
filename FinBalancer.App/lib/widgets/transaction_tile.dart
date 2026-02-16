import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/category.dart' as app_models;
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final app_models.TransactionCategory? category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final NumberFormat? currencyFormat;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.onEdit,
    this.onDelete,
    this.currencyFormat,
  });

  IconData _getIconForName(String iconName) {
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
      'credit_card': Icons.credit_card,
      'handshake': Icons.handshake,
      'build': Icons.build,
      'home_repair_service': Icons.home_repair_service,
      'bolt': Icons.bolt,
      'local_gas_station': Icons.local_gas_station,
      'subscriptions': Icons.subscriptions,
      'health_and_safety': Icons.health_and_safety,
    };
    return icons[iconName] ?? Icons.receipt;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final fmt = currencyFormat ?? NumberFormat.currency(locale: 'en_US', symbol: '€');
    final dateFormat = DateFormat('dd.MM.yyyy');

    return InkWell(
        onTap: onEdit != null ? () => onEdit!() : null,
        onLongPress: onDelete != null ? () {
          showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(AppLocalizations.of(context)?.deleteTransactionConfirm ?? 'Izbriši transakciju?'),
              content: Text(AppLocalizations.of(context)?.deleteTransactionConfirmMessage ?? 'Jeste li sigurni da želite izbrisati transakciju?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)?.cancel ?? 'Odustani')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context)?.delete ?? 'Izbriši', style: TextStyle(color: AppTheme.expense(context)))),
              ],
            ),
          ).then((ok) { if (ok == true) onDelete?.call(); });
        } : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
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
                color: (isIncome ? AppTheme.income(context) : AppTheme.expense(context))
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForName(category?.icon ?? ''),
                color: isIncome ? AppTheme.income(context) : AppTheme.expense(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? AppLocalizations.of(context)?.unknown ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.note ?? dateFormat.format(transaction.dateCreated),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isIncome ? AppTheme.income(context) : AppTheme.expense(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        ),
      );
  }
}
