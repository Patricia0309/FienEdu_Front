import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Pon aquí la IP de tu servidor de DigitalOcean
  final String baseUrl = "http://192.168.1.9:8000";

  // Paso 1: Pedir el código
  Future<bool> recoverPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/recover-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response.statusCode == 200;
  }

  // Paso 2: Cambiar la contraseña
  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );
    return response.statusCode == 200;
  }
}
