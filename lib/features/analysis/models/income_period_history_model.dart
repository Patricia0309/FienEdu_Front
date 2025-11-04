// lib/features/analysis/models/income_period_history_model.dart
class IncomePeriodHistory {
  final int incomePeriodId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalSpent;
  final double remainingBudget;
  final bool isActive;

  IncomePeriodHistory({
    required this.incomePeriodId,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalSpent,
    required this.remainingBudget,
    required this.isActive,
  });

  factory IncomePeriodHistory.fromJson(Map<String, dynamic> json) {
    return IncomePeriodHistory(
      incomePeriodId: json['income_period_id'] as int? ?? 0,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}