class Transaction {
  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String walletId;
  final String? note;
  final DateTime dateCreated;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    this.note,
    required this.dateCreated,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      categoryId: json['categoryId'] as String,
      walletId: json['walletId'] as String,
      note: json['note'] as String?,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'walletId': walletId,
      'note': note,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'walletId': walletId,
      'note': note,
    };
  }
}
