// lib/features/analysis/models/budget_tendency_model.dart
class BudgetTendency {
  final double percentageChange;
  // Tu schema puede tener más campos, pero este es el clave
  
  BudgetTendency({required this.percentageChange});

  factory BudgetTendency.fromJson(Map<String, dynamic> json) {
    // Asegúrate que el nombre 'percentage_change' coincida
    // con el JSON que manda tu API
    return BudgetTendency(
      percentageChange: (json['percentage_change'] as num?)?.toDouble() ?? 0.0,
    );
  }
}