import 'dart:convert';
import '../services/api_service.dart';
import '../../features/budgets/models/budget_status_model.dart';
import '../../features/budgets/models/income_period_model.dart';

class BudgetService {
  final ApiService _apiService = ApiService();

  // Crea un nuevo período de ingresos (presupuesto)
  Future<void> createIncomePeriod({
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Convertimos las fechas a formato ISO 8601 String, que es lo que FastAPI espera
    final Map<String, dynamic> data = {
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    // Hacemos la llamada POST a través de nuestro ApiService
    // Asumiendo que tu ApiService maneja la autenticación automáticamente
    await _apiService.post('/budgets/income-period', data);
  }

  // Obtiene el estado actual del presupuesto
  Future<BudgetStatus?> getBudgetStatus() async {
    try {
      final response = await _apiService.get('/budgets/status');
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
    required int periodId,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final Map<String, dynamic> data = {
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
    // Llama al endpoint PUT con el ID en la URL
    await _apiService.put('/budgets/income-period/$periodId', data);
  }

  // --- NUEVA FUNCIÓN (Opcional, si necesitas obtener un período específico) ---
  Future<IncomePeriod> getIncomePeriodById(int periodId) async {
    final response = await _apiService.get('/budgets/income-period/$periodId');
    final periodJson = json.decode(response.body);
    return IncomePeriod.fromJson(periodJson);
  }

  // Para Tarjeta 2: Historial de Presupuestos
  Future<List<IncomePeriod>> getBudgetHistory() async {
    final response = await _apiService.get('/budgets/history');
    final List<dynamic> listJson = json.decode(response.body);
    return listJson.map((json) => IncomePeriod.fromJson(json)).toList();
  }
}
