import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 1. Apuntamos a la dirección IP especial para el emulador de Android
  static const String _baseUrl = 'http://10.0.2.2:8000';

  // --- MÉTODO PARA REGISTRAR UN ESTUDIANTE ---
  // 2. Ahora acepta displayName para que coincida con tu backend
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // 3. El endpoint ahora es /students/
    final url = Uri.parse('$_baseUrl/students/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // 4. El cuerpo del mensaje coincide con el schema `StudentCreate` de FastAPI
        body: json.encode({
          'email': email,
          'password': password,
          'display_name': displayName,
        }),
      );

      if (response.statusCode == 201) {
        // 201 Creado
        print('Registro exitoso en el backend');
      } else {
        // 5. Manejamos errores específicos del backend
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['detail'] ?? 'Fallo al registrarse';
        print('Error en el registro: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Excepción en signUp: $e');
      throw Exception('No se pudo conectar al servidor. ¿Está encendido?');
    }
  }

  // --- MÉTODO PARA INICIAR SESIÓN ---
  // Tu backend usa autenticación con token. El endpoint suele ser /token
  // y espera los datos en un formato especial (form data).
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/token',
    ); // Asumiendo un endpoint de token estándar

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email, // FastAPI OAuth2 espera 'username'
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String accessToken = responseData['access_token'];
        print('Inicio de sesión exitoso. Token recibido.');
        // TODO: Guardar este token de forma segura en el dispositivo
        return accessToken;
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['detail'] ?? 'Credenciales incorrectas';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Excepción en signIn: $e');
      throw Exception('No se pudo conectar al servidor.');
    }
  }
}
