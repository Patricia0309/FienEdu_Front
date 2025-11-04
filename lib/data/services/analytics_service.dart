import 'dart:convert';
import 'api_service.dart';
import '../../features/analysis/models/profile_response_model.dart';
import '../../features/analysis/models/apriori_rule_model.dart';
import '../../features/analysis/models/budget_tendency_model.dart';

class AnalyticsService {
  final ApiService _apiService = ApiService();

  // Tarjeta 1: Perfil K-Means
  Future<ProfileResponse> getProfile() async {
    final response = await _apiService.post('/analytics/profile', {});
    return ProfileResponse.fromJson(json.decode(response.body));
  }

  // Tarjeta 5: Reglas Apriori
  Future<List<AprioriRule>> getRules() async {
    final response = await _apiService.get('/analytics/rules');
    final List<dynamic> listJson = json.decode(response.body);
    return listJson.map((json) => AprioriRule.fromJson(json)).toList();
  }

  // Tarjeta 4: Tendencia de Gasto
  Future<BudgetTendency> getTendency() async {
    final response = await _apiService.get('/analytics/tendency');
    return BudgetTendency.fromJson(json.decode(response.body));
  }
}
