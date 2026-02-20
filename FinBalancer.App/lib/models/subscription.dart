class SubscriptionStatus {
  final bool isPremium;
  final DateTime? expiresAt;
  final String? productId;
  final String? platform;

  const SubscriptionStatus({
    required this.isPremium,
    this.expiresAt,
    this.productId,
    this.platform,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isPremium: json['isPremium'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      productId: json['productId'] as String?,
      platform: json['platform'] as String?,
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String productId;
  final String appleProductId;
  final String googleProductId;
  final String? paypalPlanId;
  final String duration;
  final double price;
  final String currency;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.productId,
    required this.appleProductId,
    required this.googleProductId,
    this.paypalPlanId,
    required this.duration,
    required this.price,
    required this.currency,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      productId: json['productId'] as String,
      appleProductId: json['appleProductId'] as String? ?? json['productId'] as String,
      googleProductId: json['googleProductId'] as String? ?? json['productId'] as String,
      paypalPlanId: json['paypalPlanId'] as String?,
      duration: json['duration'] as String? ?? 'monthly',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
    );
  }
}
