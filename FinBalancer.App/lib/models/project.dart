class Project {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      color: json['color'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': name,
      'description': description,
      'color': color,
    };
  }
}
