class Achievement {
  final String id;
  final String key;
  final String name;
  final String icon;
  final String description;
  final String period; // daily, monthly, yearly, weekly, lifetime
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.key,
    required this.name,
    required this.icon,
    required this.description,
    this.period = 'lifetime',
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  String get periodLabel {
    switch (period) {
      case 'daily': return 'Daily';
      case 'weekly': return 'Weekly';
      case 'monthly': return 'Monthly';
      case 'yearly': return 'Yearly';
      default: return 'Lifetime';
    }
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id']?.toString() ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      description: json['description'] as String? ?? '',
      period: json['period'] as String? ?? 'lifetime',
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt'] as String) : null,
    );
  }
}
