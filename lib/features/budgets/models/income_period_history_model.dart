// lib/features/budgets/models/income_period_history_model.dart

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
      incomePeriodId: json['income_period_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalIncome: (json['total_income'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      remainingBudget: (json['remaining_budget'] as num).toDouble(),
      isActive: json['is_active'] ?? false,
    );
  }
}
