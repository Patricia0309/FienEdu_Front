// lib/features/analysis/models/budget_tendency_model.dart
import 'dart:convert';

// Funciones para decodificar (no cambian)
BudgetTendency budgetTendencyFromJson(String str) =>
    BudgetTendency.fromJson(json.decode(str));

class BudgetTendency {
  // Campos del modelo (los que ya tenías)
  final double percentageChange;
  final String direction;
  final String message;
  final double currentPeriodSpending;
  final double previousPeriodSpending;

  // Constructor (no cambia)
  BudgetTendency({
    required this.percentageChange,
    required this.direction,
    required this.message,
    required this.currentPeriodSpending,
    required this.previousPeriodSpending,
  });

  // --- ¡AQUÍ ESTÁ LA MAGIA! ---
  // Reemplaza tu factory 'fromJson' con este
  factory BudgetTendency.fromJson(Map<String, dynamic> json) {
    // 1. Accedemos a los objetos anidados de forma segura
    final comparisonData = json['comparison'] as Map<String, dynamic>?;
    final currentPeriodData = json['current_period'] as Map<String, dynamic>?;
    final previousPeriodData = json['previous_period'] as Map<String, dynamic>?;

    // 2. Extraemos los valores
    final double percentage =
        comparisonData?['spending_change_percentage']?.toDouble() ?? 0.0;
    final double currentSpending =
        currentPeriodData?['total_spent']?.toDouble() ?? 0.0;
    final double previousSpending =
        previousPeriodData?['total_spent']?.toDouble() ?? 0.0;

    // 3. Calculamos la 'direction' y el 'message' aquí mismo
    // (ya que la API no los envía)
    final String calcDirection = percentage > 0
        ? 'increase'
        : (percentage < 0 ? 'decrease' : 'neutral');
    final String trendText = percentage > 0 ? 'aumentaron' : 'disminuyeron';
    final String calcMessage =
        'Tus gastos $trendText ${percentage.abs().toStringAsFixed(0)}% respecto al período anterior';

    // 4. Retornamos el objeto construido
    return BudgetTendency(
      percentageChange: percentage,
      direction: calcDirection,
      message: calcMessage,
      currentPeriodSpending: currentSpending,
      previousPeriodSpending: previousSpending,
    );
  }
}
