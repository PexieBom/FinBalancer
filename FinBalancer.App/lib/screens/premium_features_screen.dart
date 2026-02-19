import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import '../theme/app_theme.dart';

class PremiumFeaturesScreen extends StatefulWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen> {
  List<ProductDetails> _storeProducts = [];
  bool _productsLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubscriptionData();
    });
  }

  Future<void> _loadSubscriptionData() async {
    final sub = context.read<SubscriptionProvider>();
    final app = context.read<AppProvider>();
    final userId = app.user?.id;
    await sub.loadStatus(userId);
    await sub.loadPlans();
    if (await sub.isStoreAvailable && sub.plans.isNotEmpty) {
      _loadStoreProducts(sub.plans);
    }
  }

  Future<void> _loadStoreProducts(List<SubscriptionPlan> plans) async {
    if (!mounted) return;
    setState(() => _productsLoading = true);
    try {
      final productIds = defaultTargetPlatform == TargetPlatform.iOS
          ? plans.map((p) => p.appleProductId).toSet()
          : plans.map((p) => p.googleProductId).toSet();
      final response = await InAppPurchase.instance.queryProductDetails(productIds);
      if (response.notFoundIDs.isEmpty && response.productDetails.isNotEmpty) {
        setState(() => _storeProducts = response.productDetails);
      }
    } catch (_) {}
    if (mounted) setState(() => _productsLoading = false);
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
      body: Consumer2<SubscriptionProvider, AppProvider>(
        builder: (context, sub, app, _) {
          if (sub.error != null)
            WidgetsBinding.instance.addPostFrameCallback((_) => sub.clearError());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sub.isPremium) _buildPremiumActiveBanner(sub, isDark),
                if (sub.isPremium) const SizedBox(height: 24),
                _FeatureSection(
                  title: 'Free',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  features: const [
                    'Dashboard with balance overview',
                    'Basic transactions (add, edit, delete)',
                    'Up to 3 wallets',
                    'Up to 5 categories',
                    'Basic statistics',
                    'Goals (up to 2)',
                    'Export to CSV',
                  ],
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                _FeatureSection(
                  title: 'Premium',
                  icon: Icons.star,
                  color: Colors.amber,
                  features: const [
                    'Unlimited wallets',
                    'Unlimited categories',
                    'Custom categories with icons',
                    'Advanced statistics & analytics',
                    'Unlimited goals',
                    'Export to PDF, JSON',
                    'Budgeting',
                    'Budget alerts',
                    'Priority support',
                  ],
                  isDark: isDark,
                  isHighlighted: sub.isPremium,
                ),
                const SizedBox(height: 24),
                if (!sub.isPremium) ...[
                  Text(
                    l10n.choosePlan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildSubscriptionActions(context, sub, app),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumActiveBanner(SubscriptionProvider sub, bool isDark) {
    final expires = sub.status.expiresAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.amber.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Active',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (expires != null)
                  Text(
                    'Expires: ${expires.day}/${expires.month}/${expires.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions(
    BuildContext context,
    SubscriptionProvider sub,
    AppProvider app,
  ) {
    final userId = app.user?.id ?? '';
    final storeAvailable = sub.isStoreAvailable;

    return FutureBuilder<bool>(
      future: storeAvailable,
      builder: (context, snapshot) {
        final available = snapshot.data ?? false;

        if (sub.isPremium) {
          return OutlinedButton.icon(
            onPressed: sub.isLoading
                ? null
                : () => sub.restorePurchases(userId),
            icon: sub.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Restore purchases'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.accent(context)),
            ),
          );
        }

        if (!available) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sub.plans.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...sub.plans.map((plan) {
                  final priceStr = '${plan.price.toStringAsFixed(2)} ${plan.currency}/${plan.duration == 'yearly' ? 'year' : 'month'}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                plan.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            priceStr,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Available on App Store and Google Play',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              Text(
                'Open the app on iOS or Android to subscribe.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sub.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.expense(context).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.expense(context)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sub.error!)),
                  ],
                ),
              ),
            ],
            if (_productsLoading || sub.plans.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...sub.plans.map((plan) {
                ProductDetails? product;
                for (final p in _storeProducts) {
                  if (p.id == plan.appleProductId || p.id == plan.googleProductId) {
                    product = p;
                    break;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: userId.isEmpty || sub.isPurchasing || product == null
                        ? null
                        : () {
                            if (product != null) {
                              sub.purchaseSubscription(
                                userId: userId,
                                product: product,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: sub.isPurchasing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        : Text(
                            product != null
                                ? '${plan.name} - ${product.price}'
                                : plan.name,
                          ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            TextButton(
              onPressed: userId.isEmpty || sub.isLoading
                  ? null
                  : () => sub.restorePurchases(userId),
              child: const Text('Restore purchases'),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> features;
  final bool isDark;
  final bool isHighlighted;

  const _FeatureSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.features,
    required this.isDark,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? Border.all(color: Colors.amber, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? Colors.amber.withOpacity(0.2)
                : (isDark ? Colors.black54 : Colors.black.withOpacity(0.08)),
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
              if (isHighlighted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
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
