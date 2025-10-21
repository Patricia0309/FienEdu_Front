// lib/features/profile/models/student_model.dart
import '../../inicial_setup/models/category_model.dart'; // Importa el modelo de Categoría

class Student {
  final int id;
  final String email;
  final String displayName;
  final List<Category> favoriteCategories;

  const Student({
    required this.id,
    required this.email,
    required this.displayName,
    this.favoriteCategories = const [],
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    var favCategoriesFromJson = json['favorite_categories'] as List? ?? [];
    List<Category> favCategoryList = favCategoriesFromJson.map((catJson) => Category.fromJson(catJson)).toList();
    return Student(
      id: json['id'],
      email: json['email'] ?? '', // Usa un string vacío si el email es nulo
      displayName: json['display_name'],
    );
  }
}
