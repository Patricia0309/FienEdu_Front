// lib/data/services/user_service.dart

import 'dart:convert';
import '../../features/profile/models/student_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Obtiene los datos del usuario actualmente logueado
  Future<Student> getMe() async {
    final response = await _apiService.get('/students/me');
    final studentJson = json.decode(response.body);
    return Student.fromJson(studentJson);
  }
}
