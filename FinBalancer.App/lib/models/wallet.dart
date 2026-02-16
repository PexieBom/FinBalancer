class Wallet {
  final String id;
  final String name;
  final double balance;
  final String currency;
  final bool isMain;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    this.currency = 'EUR',
    this.isMain = false,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      isMain: json['isMain'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'currency': currency,
      'isMain': isMain,
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': name,
      'balance': balance,
      'currency': currency,
    };
  }

  Wallet copyWith({String? id, String? name, double? balance, String? currency, bool? isMain}) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isMain: isMain ?? this.isMain,
    );
  }
}
