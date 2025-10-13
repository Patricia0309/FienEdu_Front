
import 'package:flutter/material.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../models/category_model.dart';
import '../widgets/category_card.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  // 1. Usamos nuestro nuevo modelo y llenamos la lista con tus datos
  final List<Category> _allCategories = const [
    Category(title: 'Hogar y Servicios', icon: '🏠', description: 'Incluye: Renta/Alojamiento, Servicios, Internet y Telefonía, Mantenimiento y Limpieza.'),
    Category(title: 'Educación', icon: '📚', description: 'Incluye: Colegiatura/Matrícula, Libros y Materiales, Cursos/Certificaciones, Copias/Impresiones.'),
    Category(title: 'Salud y Bienestar', icon: '❤️', description: 'Incluye: Seguro Médico/Consultas, Medicamentos, Gimnasio/Actividad deportiva, Terapia/Bienestar mental.'),
    Category(title: 'Deudas y Obligaciones', icon: '💳', description: 'Incluye: Pago de Tarjeta de Crédito, Préstamos, Suscripciones.'),
    Category(title: 'Alimentación', icon: '🍔', description: 'Incluye: Supermercado, Comidas Fuera/Domicilio, Antojos y Snacks.'),
    Category(title: 'Transporte', icon: '🚗', description: 'Incluye: Transporte Público, Apps de Transporte, Gasolina, Mantenimiento/Estacionamiento.'),
    Category(title: 'Compras y Cuidado Personal', icon: '🛍️', description: 'Incluye: Ropa y Calzado, Cuidado Personal, Tecnología y Gadgets, Regalos.'),
    Category(title: 'Ocio y Vida Social', icon: '🎉', description: 'Incluye: Salidas con amigos, Cine/Conciertos, Suscripciones de Entretenimiento, Hobbies, Viajes.'),
    Category(title: 'Ahorro e Inversión', icon: '💰', description: 'Aportaciones voluntarias a cuentas de ahorro, fondos de inversión, AFORE, etc.'),
    Category(title: 'Gastos Hormiga', icon: '🐜', description: 'Pequeños gastos diarios no planificados como cafés, propinas, snacks, etc.'),
  ];

  // 2. La lista de seleccionados ahora guardará objetos de tipo Category
  final List<Category> _selectedCategories = [];

  void _toggleCategory(Category category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  // 3. Función para mostrar el modal de información
  void _showInfoDialog(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(category.title, style: AppTextStyles.heading),
            ],
          ),
          content: Text(category.description, style: AppTextStyles.body),
          actions: [
            PrimaryButton(
              text: 'Entendido',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personaliza tu experiencia', style: AppTextStyles.title),
              const SizedBox(height: 12),
              Text('Selecciona las categorías que más usas', style: AppTextStyles.body),
              const SizedBox(height: 20),
              
              // 4. Reemplazamos Wrap con GridView.builder
              Expanded(
                child: GridView.builder(
                  itemCount: _allCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columnas
                    crossAxisSpacing: 16, // Espacio horizontal
                    mainAxisSpacing: 16,  // Espacio vertical
                    childAspectRatio: 1.1, // Relación de aspecto de las tarjetas
                  ),
                  itemBuilder: (context, index) {
                    final category = _allCategories[index];
                    return CategoryCard(
                      icon: category.icon,
                      title: category.title,
                      isSelected: _selectedCategories.contains(category),
                      onTap: () => _toggleCategory(category),
                      onInfoTap: () => _showInfoDialog(category),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Continuar', // El texto del botón final
                onPressed: () {
                  // TODO: Guardar las categorías seleccionadas
                  print('Categorías: ${_selectedCategories.map((c) => c.title).toList()}');
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}