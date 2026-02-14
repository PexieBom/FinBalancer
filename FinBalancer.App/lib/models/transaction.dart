class Transaction {
  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String? subcategoryId;
  final String walletId;
  final String? note;
  final List<String> tags;
  final String? project;
  final DateTime dateCreated;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.subcategoryId,
    required this.walletId,
    this.note,
    this.tags = const [],
    this.project,
    required this.dateCreated,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'];
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      categoryId: json['categoryId'] as String,
      subcategoryId: json['subcategoryId'] as String?,
      walletId: json['walletId'] as String,
      note: json['note'] as String?,
      tags: tagsList != null
          ? (tagsList as List).map((e) => e.toString()).toList()
          : [],
      project: json['project'] as String?,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'walletId': walletId,
      'note': note,
      'tags': tags,
      'project': project,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'walletId': walletId,
      'note': note,
      'tags': tags.isNotEmpty ? tags : null,
      'project': project,
    };
  }
}
