import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/category.dart' as app_models;
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final app_models.TransactionCategory? category;
  final VoidCallback? onDelete;
  final NumberFormat? currencyFormat;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.onDelete,
    this.currencyFormat,
  });

  IconData _getIconForName(String iconName) {
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
    };
    return icons[iconName] ?? Icons.receipt;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final fmt = currencyFormat ?? NumberFormat.currency(locale: 'en_US', symbol: '€');
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Dismissible(
      key: Key(transaction.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.expense(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
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
