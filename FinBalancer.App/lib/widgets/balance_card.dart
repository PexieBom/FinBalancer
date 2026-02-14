import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color? color;
  final IconData? icon;
  final NumberFormat? currencyFormat;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    this.color,
    this.icon,
    this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final format = currencyFormat ?? NumberFormat.currency(locale: 'en_US', symbol: '€');
    return Container(
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
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            format.format(amount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color ?? AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
