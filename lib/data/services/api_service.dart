// lib/data/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Necesitamos el AuthService para obtener el token

class ApiService {
  // Usamos las mismas bases que en AuthService
  static const String _baseUrl = 'http://10.0.2.2:8000';
  final AuthService _authService = AuthService();

  // --- MÉTODO PRIVADO PARA OBTENER LOS HEADERS ---
  // Este método se encarga de obtener el token y añadirlo a los headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token != null) {
      // Si tenemos token, lo añadimos al header de autorización
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      // Si no hay token, solo enviamos el header de contenido
      return {'Content-Type': 'application/json'};
    }
  }

  // --- MÉTODOS PÚBLICOS PARA GET, POST, PUT, ETC. ---

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    _handleResponse(response); // Manejamos errores comunes
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    _handleResponse(response);
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
    _handleResponse(response);
    return response;
  }

  // --- MANEJO DE ERRORES CENTRALIZADO ---
  void _handleResponse(http.Response response) {
    // Si la respuesta no es exitosa (ej. 401 Unauthorized, 404 Not Found, 500 Server Error)
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print(
        'Error en la petición API: ${response.statusCode} ${response.body}',
      );
      final responseBody = json.decode(response.body);
      final errorMessage =
          responseBody['detail'] ?? 'Ocurrió un error en la petición';
      throw Exception(errorMessage);
    }
  }
}
