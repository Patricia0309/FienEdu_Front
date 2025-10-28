// lib/features/initial_setup/models/category_model.dart

class Category {
  final int id;
  final String title;
  final String icon;
  final String description;

  const Category({
    required this.id,
    required this.title,
    this.icon = '❓',
    this.description = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final String categoryName =
        json['name'] as String? ?? 'Sin nombre'; // Safe read
    return Category(
      id: json['id'] as int? ?? 0, // Also make ID safe
      title: categoryName,
      icon: getIconForCategory(categoryName),
      // Description is added later in Flutter
    );
  }

  // 1. Quitamos el guion bajo para hacer la función PÚBLICA
  static String getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'hogar y servicios':
        return '🏠';
      case 'educación':
        return '📚';
      case 'salud y bienestar':
        return '❤️';
      case 'deudas y obligaciones':
        return '💳';
      case 'alimentación':
        return '🍔';
      case 'transporte':
        return '🚗';
      case 'compras y cuidado personal':
        return '🛍️';
      case 'ocio y vida social':
        return '🎉';
      case 'ahorro e inversión':
        return '💰';
      case 'gastos hormiga':
        return '🐜';
      default:
        return '❓';
    }
  }
}
