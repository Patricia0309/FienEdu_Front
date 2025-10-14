// lib/features/initial_setup/models/category_model.dart

class Category {
  final int id; // <-- 1. Añadimos el ID
  final String title;
  final String icon;
  final String description;

  const Category({
    required this.id,
    required this.title,
    this.icon = '❓', // Damos valores por defecto por si acaso
    this.description = '',
  });

  // 2. "Constructor de fábrica" para crear un objeto Category desde un JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['name'], // El backend usa 'name', nosotros 'title'
      // Aquí podrías tener una lógica para asignar un emoji basado en el nombre
      icon: _getIconForCategory(json['name']),
    );
  }

  // Helper para asignar emojis (puedes expandir esto)
  static String _getIconForCategory(String name) {
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
