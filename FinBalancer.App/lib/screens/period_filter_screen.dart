import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../l10n/app_localizations.dart';

/// Poseban ekran za odabir filtera perioda transakcija.
class PeriodFilterScreen extends StatelessWidget {
  const PeriodFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<DataProvider>();

    final options = [
      (id: 'month', label: l10n.thisMonth),
      (id: '1m', label: l10n.last1Month),
      (id: '3m', label: l10n.last3Months),
      (id: '6m', label: l10n.last6Months),
      (id: '12m', label: l10n.last12Months),
      (id: 'year', label: l10n.thisYear),
      (id: 'custom', label: l10n.customRange),
    ];

    Future<void> selectPeriod(String id) async {
      if (id == 'custom') {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: provider.filterDateFrom != null && provider.filterDateTo != null
              ? DateTimeRange(start: provider.filterDateFrom!, end: provider.filterDateTo!)
              : DateTimeRange(
                  start: DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
                  end: DateTime.now(),
                ),
        );
        if (range != null && context.mounted) {
          provider.setCustomPeriod(range.start, range.end);
          await provider.loadTransactions();
          if (context.mounted) Navigator.pop(context);
        }
        return;
      }
      switch (id) {
        case 'month':
          provider.setCurrentMonth();
          break;
        case '1m':
          provider.setPeriodMonths(1);
          break;
        case '3m':
          provider.setPeriodMonths(3);
          break;
        case '6m':
          provider.setPeriodMonths(6);
          break;
        case '12m':
          provider.setPeriodMonths(12);
          break;
        case 'year':
          provider.setPeriodThisYear();
          break;
      }
      await provider.loadTransactions();
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filter),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: options.map((opt) {
          final selected = provider.selectedPeriodId == opt.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(opt.label),
              trailing: selected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              selected: selected,
              onTap: () => selectPeriod(opt.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}
