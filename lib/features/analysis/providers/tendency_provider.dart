// lib/features/analysis/providers/tendency_provider.dart
import 'package:flutter/material.dart';
// 1. Importa tu modelo (asumo que la ruta es algo así)
import '../models/budget_tendency_model.dart';
// 2. Importa tu SERVICIO (el que SÍ sabe de la API)
import '../../../data/services/analytics_service.dart';

class TendencyProvider extends ChangeNotifier {
  // 3. Usa tu AnalyticsService
  final AnalyticsService _analyticsService = AnalyticsService();

  BudgetTendency? _tendency;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para que la UI pueda leer el estado
  BudgetTendency? get tendency => _tendency;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 4. La función de carga ¡YA NO NECESITA EL TOKEN como parámetro!
  // Tu ApiService lo maneja internamente de forma automática.
  Future<void> fetchTendencyData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a la UI que estamos cargando

    try {
      // 5. Llama al método correcto en tu servicio
      _tendency = await _analyticsService.getTendency();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners(); // Notifica a la UI que terminamos (con datos o con error)
  }
}
