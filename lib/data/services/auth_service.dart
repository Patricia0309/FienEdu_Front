// lib/data/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8000';
  final _storage = const FlutterSecureStorage();

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final url = Uri.parse('$_baseUrl/students/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'display_name': displayName,
        }),
      );

      if (response.statusCode == 201) {
        print('Registro exitoso en el backend');
        await signIn(email: email, password: password);
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['detail'] ?? 'Fallo al registrarse';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Excepción en signUp (llamada real): $e');
      throw Exception('No se pudo conectar al servidor. ¿Está encendido?');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final url = Uri.parse('$_baseUrl/token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String accessToken = responseData['access_token'];
        await _saveToken(accessToken);
        print('Inicio de sesión exitoso. Token guardado.');
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['detail'] ?? 'Credenciales incorrectas';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Excepción en signIn (llamada real): $e');
      throw Exception('No se pudo conectar al servidor.');
    }
  }
}
