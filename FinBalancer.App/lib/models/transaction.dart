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
  final String? projectId;
  final DateTime dateCreated;
  final bool isYearlyExpense;

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
    this.projectId,
    required this.dateCreated,
    this.isYearlyExpense = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'];
    return Transaction(
      id: json['id']?.toString() ?? '',
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
      projectId: json['projectId']?.toString(),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      isYearlyExpense: json['isYearlyExpense'] == true,
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
      'projectId': projectId,
      'dateCreated': dateCreated.toIso8601String(),
      'isYearlyExpense': isYearlyExpense,
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
      'tags': tags.isEmpty ? [] : tags,
      'project': project,
      'projectId': projectId,
      'isYearlyExpense': isYearlyExpense,
    };
  }
}
