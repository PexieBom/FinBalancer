import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/achievement.dart';
import '../providers/data_provider.dart';
import '../l10n/app_localizations.dart';

class AchievementsListScreen extends StatelessWidget {
  const AchievementsListScreen({super.key});

  IconData _iconFor(String name) {
    const m = {
      'touch_app': Icons.touch_app,
      'flag': Icons.flag,
      'emoji_events': Icons.emoji_events,
      'local_fire_department': Icons.local_fire_department,
      'savings': Icons.savings,
      'schedule': Icons.schedule,
      'star': Icons.star,
    };
    return m[name] ?? Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(l10n.achievements, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.achievements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final achievements = provider.achievements;
          if (achievements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No achievements yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add transactions and reach goals to unlock achievements', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }
          final unlocked = achievements.where((a) => a.isUnlocked).toList();
          final locked = achievements.where((a) => !a.isUnlocked).toList();
          final badgeBg = isDark ? Colors.amber.shade900.withOpacity(0.4) : Colors.amber.shade50;
          final badgeLocked = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
          final iconColor = isDark ? Colors.amber.shade400 : Colors.amber.shade700;
          return RefreshIndicator(
            onRefresh: provider.loadAll,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (unlocked.isNotEmpty) ...[
                  Text('Unlocked', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...unlocked.map((a) => _buildTile(context, a, true, badgeBg, iconColor)),
                  const SizedBox(height: 24),
                ],
                Text('All Achievements', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...achievements.map((a) => _buildTile(context, a, a.isUnlocked, a.isUnlocked ? badgeBg : badgeLocked, a.isUnlocked ? iconColor : Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(BuildContext context, Achievement a, bool unlocked, Color bgColor, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? Colors.amber.shade200 : Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(_iconFor(a.icon), color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(a.periodLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                if (a.unlockedAt != null)
                  Text('Unlocked: ${a.unlockedAt!.toString().split(' ')[0]}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.green.shade700)),
              ],
            ),
          ),
          if (unlocked) Icon(Icons.check_circle, color: Colors.green, size: 24) else Icon(Icons.lock_outline, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}
