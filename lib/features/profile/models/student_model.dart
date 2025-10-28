// lib/features/profile/models/student_model.dart
import '../../inicial_setup/models/category_model.dart'; // Importa el modelo de Categoría

class Student {
  final int id;
  final String email;
  final String? displayName;
  final List<Category> favoriteCategories;

  const Student({
    required this.id,
    required this.email,
    this.displayName,
    this.favoriteCategories = const [],
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    var favCategoriesFromJson =
        json.containsKey('favorite_categories') &&
            json['favorite_categories'] is List
        ? json['favorite_categories'] as List
        : []; // Si no existe o no es lista, usa una lista vacía
    // Asegúrate de que Category.fromJson exista y funcione
    List<Category> favCategoryList = favCategoriesFromJson
        .map(
          (catJson) => Category.fromJson(catJson as Map<String, dynamic>),
        ) // Convierte cada item
        .toList();
    return Student(
      id: json['id'],
      email:
          json['email'] as String? ??
          '', // Usa un string vacío si el email es nulo
      displayName: json['display_name'] as String? ?? 'Usuario',
      favoriteCategories: favCategoryList,
    );
  }
}
