// lib/features/budgets/models/budget_status_model.dart

class BudgetStatus {
  final int incomePeriodId;
  final double totalIncome;
  final DateTime startDate;
  final DateTime endDate;
  final double totalSpent;
  final double remainingBudget;
  final int daysLeft;
  final bool isActive;

  const BudgetStatus({
    required this.incomePeriodId,
    required this.totalIncome,
    required this.startDate,
    required this.endDate,
    required this.totalSpent,
    required this.remainingBudget,
    required this.daysLeft,
    required this.isActive,
  });

  factory BudgetStatus.fromJson(Map<String, dynamic> json) {
    return BudgetStatus(
      incomePeriodId: json['income_period_id'],
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      daysLeft: json['days_left'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}