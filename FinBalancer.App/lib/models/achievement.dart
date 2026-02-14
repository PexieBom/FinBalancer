class Achievement {
  final String id;
  final String key;
  final String name;
  final String icon;
  final String description;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.key,
    required this.name,
    required this.icon,
    required this.description,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt'] as String) : null,
    );
  }
}
