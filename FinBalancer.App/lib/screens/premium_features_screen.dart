import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Ekran koji prikazuje listu free vs premium značajki
class PremiumFeaturesScreen extends StatelessWidget {
  const PremiumFeaturesScreen({super.key});

  static const _freeFeatures = [
    'Dashboard with balance overview',
    'Basic transactions (add, edit, delete)',
    'Up to 3 wallets',
    'Up to 5 categories',
    'Basic statistics',
    'Goals (up to 2)',
    'Export to CSV',
  ];

  static const _premiumFeatures = [
    'Unlimited wallets',
    'Unlimited categories',
    'Custom categories with icons',
    'Advanced statistics & analytics',
    'Unlimited goals',
    'Export to PDF, JSON',
    'Projects & budgeting',
    'Budget alerts',
    'Priority support',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.premiumFeatures,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FeatureSection(
              title: 'Free',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              features: _freeFeatures,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            _FeatureSection(
              title: 'Premium',
              icon: Icons.star,
              color: Colors.amber,
              features: _premiumFeatures,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> features;
  final bool isDark;

  const _FeatureSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.features,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black.withOpacity(0.08),
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
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
