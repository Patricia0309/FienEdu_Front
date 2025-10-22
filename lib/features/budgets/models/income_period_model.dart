// lib/features/budgets/models/income_period_model.dart

class IncomePeriod {
  final int id;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int studentId;

  const IncomePeriod({
    required this.id,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.studentId,
  });

  factory IncomePeriod.fromJson(Map<String, dynamic> json) {
    return IncomePeriod(
      id: json['id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? false,
      studentId: json['student_id'],
    );
  }
}