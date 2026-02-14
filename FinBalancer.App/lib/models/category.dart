class TransactionCategory {
  final String id;
  final String name;
  final String icon;
  final String type;

  TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String,
    );
  }
}
