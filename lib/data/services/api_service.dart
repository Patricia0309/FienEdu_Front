import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Asegúrate de importar esto
import '../../common/routing/navigator_key.dart';
import '../../common/routing/app_routes.dart';

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

  // --- NUEVA FUNCIÓN PARA MANEJAR EL 401 ---
  Future<void> _handleUnauthorized() async {
    // Borra el token inválido del almacenamiento seguro
    await _storage.delete(key: 'access_token');
    print('Token inválido eliminado.');

    // Usa la clave global para navegar a la pantalla de bienvenida
    // y eliminar todas las pantallas anteriores de la pila.
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.welcome, // Asegúrate que esta sea tu pantalla de login/bienvenida
      (route) => false, // Elimina todas las rutas anteriores
    );
  }

  // --- MANEJO DE ERRORES CENTRALIZADO ---
  void _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print(
        'Error en la petición API: ${response.statusCode} ${response.body}',
      );
      // Si el error es 401 (No autorizado)...
      if (response.statusCode == 401) {
        // Llama a la función para desloguear y redirigir
        _handleUnauthorized();
        // Lanza una excepción específica para que la UI sepa que fue un error de auth
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
      }
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
}
