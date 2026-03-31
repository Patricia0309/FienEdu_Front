import 'dart:convert';
import '../services/api_service.dart';
import '../../features/budgets/models/budget_status_model.dart';
import '../../features/budgets/models/income_period_model.dart';
import '../../features/analysis/models/income_period_history_model.dart';

class BudgetService {
  final ApiService _apiService = ApiService();

  // Función auxiliar para limpiar la fecha (solo año-mes-día)
  String _formatDate(DateTime date, {bool isEnd = false}) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    // Si es fin de día, le ponemos las 23:59:59 para que abarque todo el día
    final time = isEnd ? "23:59:59Z" : "00:00:00Z";
    return "$year-$month-${day}T$time";
  }

  // Crea un nuevo período de ingresos (presupuesto)
  Future<void> createIncomePeriod({
    // 1. LA DEFINICIÓN: debe aceptar 'amount', 'startDate', y 'endDate'
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 2. EL MAPA: convierte 'amount' en 'total_income' para la API
    final Map<String, dynamic> data = {
      'total_income': amount, // <-- Así lo espera la API
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate, isEnd: true),
    };

    // 3. LA LLAMADA: (esto ya estaba bien)
    await _apiService.post('/budgets/income-period', data);
  }

  // Obtiene el estado actual del presupuesto
  Future<BudgetStatus?> getBudgetStatus() async {
    try {
      final response = await _apiService.get('/budgets/status');
      if (response.body.isEmpty || response.body == 'null') return null;
      final statusJson = json.decode(response.body);
      return BudgetStatus.fromJson(statusJson);
    } catch (e) {
      // Si da error 404 (no hay período activo), devuelve null
      if (e.toString().contains('404')) {
        // Simple check for 404
        return null;
      }
      rethrow; // Re-lanza otros errores
    }
  }

  // Actualiza un período de ingresos existente
  Future<void> updateIncomePeriod({
    // 1. LA DEFINICIÓN: también debe aceptar 'amount', 'startDate', etc.
    required int periodId,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 2. EL MAPA: convierte 'amount' en 'total_income' para la API
    final Map<String, dynamic> data = {
      'total_income': amount, // <-- Así lo espera la API
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate, isEnd: true),
    };

    // 3. LA LLAMADA: (esto ya estaba bien)
    await _apiService.put('/budgets/income-period/$periodId', data);
  }

  // --- NUEVA FUNCIÓN (Opcional, si necesitas obtener un período específico) ---
  Future<IncomePeriod> getIncomePeriodById(int periodId) async {
    final response = await _apiService.get('/budgets/income-period/$periodId');
    final periodJson = json.decode(response.body);
    return IncomePeriod.fromJson(periodJson);
  }

  // Para Tarjeta 2: Historial de Presupuestos
  Future<List<IncomePeriodHistory>> getBudgetHistory() async {
    final response = await _apiService.get('/budgets/history');
    final List<dynamic> listJson = json.decode(response.body);
    // Usa el nuevo modelo IncomePeriodHistory
    return listJson.map((json) => IncomePeriodHistory.fromJson(json)).toList();
  }
}
