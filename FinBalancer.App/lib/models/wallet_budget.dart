class BudgetCurrent {
  final double budgetAmount;
  final double spent;
  final double remaining;
  final int daysRemaining;
  final double allowancePerDay;
  final String paceStatus; // OnTrack | OverPace | UnderPace
  final double overUnderPerDay;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String explanation;

  const BudgetCurrent({
    required this.budgetAmount,
    required this.spent,
    required this.remaining,
    required this.daysRemaining,
    required this.allowancePerDay,
    required this.paceStatus,
    required this.overUnderPerDay,
    required this.periodStart,
    required this.periodEnd,
    required this.explanation,
  });

  factory BudgetCurrent.fromJson(Map<String, dynamic> json) {
    return BudgetCurrent(
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      daysRemaining: json['daysRemaining'] as int,
      allowancePerDay: (json['allowancePerDay'] as num).toDouble(),
      paceStatus: json['paceStatus'] as String,
      overUnderPerDay: (json['overUnderPerDay'] as num).toDouble(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class BudgetSummary {
  final String id;
  final String walletId;
  final bool isMain;
  final BudgetCurrent current;
  /// Ime kategorije ako je budžet ograničen na kategoriju, null = praćenje svih.
  final String? categoryName;

  const BudgetSummary({
    required this.id,
    required this.walletId,
    required this.isMain,
    required this.current,
    this.categoryName,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      isMain: json['isMain'] as bool? ?? false,
      current: BudgetCurrent.fromJson(json['current'] as Map<String, dynamic>),
      categoryName: json['categoryName'] as String?,
    );
  }
}
