class Category {
  final String id;
  final String name;
  final String icon;
  final String type;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String,
    );
  }
}
