import 'dart:convert';
import 'api_service.dart';
import '../../features/analysis/models/profile_response_model.dart';
import '../../features/analysis/models/apriori_rule_model.dart';
import '../../features/analysis/models/budget_tendency_model.dart';
import '../../features/analysis/models/recommendation_model.dart';

class AnalyticsService {
  final ApiService _apiService = ApiService();

  // Tarjeta 1: Perfil K-Means
  Future<ProfileResponse> getProfile() async {
    final response = await _apiService.post('/analytics/profile', {});
    return ProfileResponse.fromJson(json.decode(response.body));
  }

  // Tarjeta 5: Reglas Apriori
  Future<List<AprioriRule>> getRules() async {
    // 1. Asegúrate que el endpoint sea el que me diste
    final response = await _apiService.get('/analytics/me/rules');

    // 2. Decodificamos usando utf8.decode para tildes (ej. "Alimentación")
    final List<dynamic> listJson = json.decode(utf8.decode(response.bodyBytes));

    // 3. Esto funcionará gracias al Paso 1
    return listJson.map((json) => AprioriRule.fromJson(json)).toList();
  }

  // Tarjeta 4: Tendencia de Gasto
  Future<BudgetTendency> getTendency() async {
    final response = await _apiService.get('/analytics/tendency');
    return BudgetTendency.fromJson(json.decode(response.body));
  }

  // Tarjeta 2: Recomendaciones
  Future<List<Recommendation>> getRecommendations() async {
    // Asumo que el endpoint completo es '/analytics/recommendations'
    // Si tu router de FastAPI es diferente, ajusta esta URL
    final response = await _apiService.get('/analytics/recommendations');

    // Usar utf8.decode para manejar tildes (como en "¡Sigue así!")
    final List<dynamic> listJson = json.decode(utf8.decode(response.bodyBytes));

    return listJson.map((json) => Recommendation.fromJson(json)).toList();
  }
}
