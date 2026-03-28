// lib/data/services/category_service.dart

import 'dart:convert';
import '../services/api_service.dart';
import '../../features/inicial_setup/models/category_model.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    // Es buena práctica añadir también una barra aquí si tu endpoint la tiene
    final response = await _apiService.get('/transactions/categories/');

    final List<dynamic> categoryListJson = json.decode(response.body);

    return categoryListJson.map((json) => Category.fromJson(json)).toList();
  }

  Future<void> updateFavoriteCategories(List<int> categoryIds) async {
    // La corrección está en esta línea:
    await _apiService.put(
      '/students/me/categories', // <-- Sin la barra final
      {'category_ids': categoryIds},
    );
  }
}
