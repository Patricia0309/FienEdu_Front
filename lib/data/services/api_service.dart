// lib/data/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Asegúrate de importar esto

class ApiService {
  // Asegúrate de que esta URL sea la correcta para tu teléfono
  static const String _baseUrl =
      //'http:// 192.168.100.179:8000'; // Usa la IP de tu PC
      'http://10.0.2.2:8000';
  final _storage =
      const FlutterSecureStorage(); // Usamos storage directamente aquí

  // --- MÉTODO PRIVADO PARA OBTENER LOS HEADERS ---
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (includeAuth) {
      // Lee el token guardado
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        // Formato EXACTO: "Bearer <token>"
        headers['Authorization'] = 'Bearer $token';
      } else {
        // Opcional: Podrías lanzar un error si esperas un token y no lo encuentras
        print(
          "ADVERTENCIA: Se intentó hacer una petición autenticada sin token.",
        );
      }
    }
    return headers;
  }

  // --- MÉTODOS PÚBLICOS PARA GET, POST, PUT, ETC. ---

  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    // Le decimos a _getHeaders si debe incluir el token o no
    final headers = await _getHeaders(includeAuth: requireAuth);

    final response = await http.get(url, headers: headers);
    _handleResponse(response);
    return response;
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: requireAuth);

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    _handleResponse(response);
    return response;
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: requireAuth);

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
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print(
        'Error en la petición API: ${response.statusCode} ${response.body}',
      );
      try {
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['detail'] ?? 'Ocurrió un error en la petición';
        throw Exception(errorMessage);
      } catch (e) {
        // Si el cuerpo no es JSON válido o no tiene 'detail'
        throw Exception(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    }
  }
}
