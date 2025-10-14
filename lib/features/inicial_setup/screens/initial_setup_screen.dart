// lib/features/initial_setup/screens/initial_setup_screen.dart

import 'package:flutter/material.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/utils/show_snackbar.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../data/services/category_service.dart';
import '../models/category_model.dart';
import '../widgets/category_card.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  // 1. Instanciamos nuestro servicio de categorías
  final CategoryService _categoryService = CategoryService();
  // 2. Creamos un 'Future' que guardará el resultado de la llamada a la API
  late Future<List<Category>> _categoriesFuture;

  final List<Category> _selectedCategories = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 3. Al iniciar la pantalla, mandamos a buscar las categorías al backend
    _categoriesFuture = _categoryService.getCategories();
  }

  void _toggleCategory(Category category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  // Lógica para el botón 'Continuar', ahora llama a la API
  void _handleContinue() async {
    setState(() => _isSaving = true);
    try {
      // Extraemos solo los IDs de las categorías seleccionadas
      final selectedIds = _selectedCategories.map((c) => c.id).toList();
      await _categoryService.updateFavoriteCategories(selectedIds);

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showInfoDialog(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(category.title, style: AppTextStyles.heading),
              ),
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
              Text(
                'Selecciona las categorías que más usas',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),

              // 4. Usamos un FutureBuilder para manejar los estados de carga de la API
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future:
                      _categoriesFuture, // Le decimos qué 'Future' debe escuchar
                  builder: (context, snapshot) {
                    // --- Caso 1: Los datos todavía están cargando ---
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // --- Caso 2: Hubo un error en la conexión ---
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar categorías: ${snapshot.error}',
                        ),
                      );
                    }
                    // --- Caso 3: Los datos llegaron con éxito ---
                    if (snapshot.hasData) {
                      final categories = snapshot.data!;
                      if (categories.isEmpty) {
                        return const Center(
                          child: Text('No se encontraron categorías.'),
                        );
                      }
                      return GridView.builder(
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            icon: category.icon,
                            title: category.title,
                            isSelected: _selectedCategories.contains(category),
                            onTap: () => _toggleCategory(category),
                            onInfoTap: () => _showInfoDialog(category),
                          );
                        },
                      );
                    }
                    // --- Caso por defecto (aunque no debería pasar) ---
                    return const Center(
                      child: Text('No hay categorías disponibles.'),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              PrimaryButton(
                text: _isSaving ? 'Guardando...' : 'Continuar',
                onPressed: _isSaving ? null : _handleContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
