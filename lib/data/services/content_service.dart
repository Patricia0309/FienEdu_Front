// lib/data/services/content_service.dart
import 'dart:convert';
import 'api_service.dart'; // Importa tu servicio base
import '../../features/learn/models/microcontent_model.dart'; // Importa el modelo

class ContentService {
  final ApiService _apiService = ApiService();

  Future<List<Microcontent>> getAllMicrocontent() async {
    // ❗️ IMPORTANTE: Ajusta esta URL a tu endpoint real.
    // Tu endpoint es @router.get("/")
    // Asumo que está en un router prefijado como '/microcontent'
    // Si tu router se llama 'content', cámbialo a '/content/'
    final response = await _apiService.get('/microcontent/');

    // Decodificamos para tildes
    final List<dynamic> listJson = json.decode(utf8.decode(response.bodyBytes));

    return listJson.map((json) => Microcontent.fromJson(json)).toList();
  }
}
