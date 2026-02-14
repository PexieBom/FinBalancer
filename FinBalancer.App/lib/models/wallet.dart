class Wallet {
  final String id;
  final String name;
  final double balance;
  final String currency;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    this.currency = 'EUR',
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'currency': currency,
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': name,
      'balance': balance,
      'currency': currency,
    };
  }

  Wallet copyWith({String? id, String? name, double? balance, String? currency}) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }
}
