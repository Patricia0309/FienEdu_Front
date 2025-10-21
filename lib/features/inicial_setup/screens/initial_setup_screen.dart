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
  final CategoryService _categoryService = CategoryService();
  late Future<List<Category>> _categoriesFuture;

  final List<Category> _selectedCategories = [];
  bool _isSaving = false;

  // 1. Guardamos las descripciones que nos diste en un mapa
  final Map<String, String> _categoryDescriptions = {
    'Hogar y Servicios':
        'Renta o alojamiento, servicios (luz, agua, gas), internet o telefonía, mantenimiento y limpieza',
    'Educación':
        'Colegiatura, libros, materiales de estudio, cursos o certificaciones, copias, impresiones',
    'Salud y Bienestar':
        'Seguro médico, consultas, medicamentos, gimnasio o actividad deportiva, terapia o bienestar mental',
    'Deudas y Obligaciones':
        'Pago de Tarjeta de Crédito, préstamos (educativos u otros), suscripciones (software, académicas)',
    'Alimentación': 'Supermercado, comidas fuera, domicilio, antojos o snacks',
    'Transporte':
        'Transporte Público, apps de transporte, gasolina, mantenimiento o estacionamiento',
    'Compras y Cuidado Personal':
        'Ropa o calzado, peluquería, barbería, productos de aseo, tecnología o gadgets',
    'Ocio y Vida Social':
        'Salidas con amigos, suscripciones de entretenimiento hobbies o pasatiempos',
    'Ahorro e Inversión': '¡Págate a ti primero!',
    'Gastos Hormiga':
        'Pequeños gastos diarios no planificados como cafés, propinas, snacks, etc.',
  };

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadAndEnrichCategories();
  }

  // Nueva función para cargar y "enriquecer" las categorías
  Future<List<Category>> _loadAndEnrichCategories() async {
    final categoriesFromApi = await _categoryService.getCategories();
    // Inyectamos la descripción y el ícono a cada categoría que viene de la API
    return categoriesFromApi
        .map(
          (category) => Category(
            id: category.id,
            title: category.title,
            icon: Category.getIconForCategory(
              category.title,
            ), // Re-usamos el helper del modelo
            description:
                _categoryDescriptions[category.title] ??
                'Sin descripción disponible.',
          ),
        )
        .toList();
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

  void _handleContinue() async {
    // 2. Añadimos la validación aquí
    if (_selectedCategories.isEmpty) {
      showErrorSnackBar(
        context,
        'Por favor, selecciona al menos una categoría.',
      );
      return; // Detiene la ejecución si no se seleccionó nada
    }

    setState(() => _isSaving = true);
    try {
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
          // 3. Ahora el content sí tendrá la descripción
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
            // ... El resto de la UI con el FutureBuilder no cambia...
            children: [
              Text('Personaliza tu experiencia', style: AppTextStyles.title),
              const SizedBox(height: 12),
              Text(
                'Selecciona las categorías que más usas',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
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

                    // --- Caso 3: Los datos llegaron con éxito y la lista NO está vacía ---
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final categories = snapshot.data!;
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

                    // --- CASO FINAL (Éxito pero sin datos, o cualquier otro estado) ---
                    // Esta es la línea que probablemente te falta.
                    // Siempre debe haber un 'return' final como red de seguridad.
                    return const Center(
                      child: Text(
                        'No hay categorías disponibles para seleccionar.',
                      ),
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
