// lib/data/services/category_service.dart

import 'dart:convert';
import '../services/api_service.dart';
import '../../features/inicial_setup/models/category_model.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  // Obtiene la lista de todas las categorías
  Future<List<Category>> getCategories() async {
    final response = await _apiService.get('/transactions/categories/');

    // El backend devuelve una lista, la decodificamos
    final List<dynamic> categoryListJson = json.decode(response.body);

    // Convertimos cada item del JSON a un objeto Category
    return categoryListJson.map((json) => Category.fromJson(json)).toList();
  }

  // Guarda las categorías favoritas del usuario
  Future<void> updateFavoriteCategories(List<int> categoryIds) async {
    await _apiService.put('/students/me/categories', {
      'category_ids': categoryIds,
    });
  }
}
