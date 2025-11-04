// Para el JSON de GET /analytics/tendency
class BudgetTendency {
  final double percentageChange;

  BudgetTendency({required this.percentageChange});

  factory BudgetTendency.fromJson(Map<String, dynamic> json) {
    return BudgetTendency(
      percentageChange: (json['percentage_change'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
