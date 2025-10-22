import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/selectable_chip.dart'; // Reutilizaremos el chip
import '../../../data/services/category_service.dart';
import '../../inicial_setup/models/category_model.dart';
import '../../../common/utils/show_snackbar.dart';

class FavoriteCategoriesSection extends StatefulWidget {
  // Recibe la lista inicial de categorías favoritas del usuario
  final List<Category> initialFavorites;
  final VoidCallback? onSaveSuccess;

  const FavoriteCategoriesSection({
    super.key,
    required this.initialFavorites,
    this.onSaveSuccess,
  });

  @override
  State<FavoriteCategoriesSection> createState() => _FavoriteCategoriesSectionState();
}

class _FavoriteCategoriesSectionState extends State<FavoriteCategoriesSection> {
  final CategoryService _categoryService = CategoryService();

  bool _isEditing = false;
  bool _isLoadingAllCategories = false;
  bool _isSaving = false;

  // Lista para guardar TODAS las categorías disponibles (solo se carga en modo edición)
  List<Category> _allCategories = [];
  // Usamos un Set de IDs para manejar eficientemente las selecciones
  late Set<int> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    // Inicializamos el Set con los IDs de las favoritas iniciales
    _selectedCategoryIds = widget.initialFavorites.map((cat) => cat.id).toSet();
  }

  // Función para entrar en modo edición y cargar todas las categorías
  Future<void> _enterEditMode() async {
    setState(() {
      _isLoadingAllCategories = true;
      _isEditing = true;
    });
    try {
      _allCategories = await _categoryService.getCategories();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Error al cargar categorías');
      _isEditing = false; // Vuelve al modo normal si hay error
    } finally {
      if (mounted) setState(() => _isLoadingAllCategories = false);
    }
  }

  // Función para guardar los cambios
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await _categoryService.updateFavoriteCategories(_selectedCategoryIds.toList());
      if (mounted) showSuccessSnackBar(context, 'Preferencias guardadas');
      widget.onSaveSuccess?.call();
      setState(() { _isEditing = false; }); // Sal del modo edición al guardar
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Error al guardar preferencias');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Función para cancelar la edición
  void _cancelEdit() {
    setState(() {
      // Restaura la selección original
      _selectedCategoryIds = widget.initialFavorites.map((cat) => cat.id).toSet();
      _isEditing = false;
    });
  }

  // Función para seleccionar/deseleccionar una categoría en modo edición
  void _toggleSelection(Category category) {
    setState(() {
      if (_selectedCategoryIds.contains(category.id)) {
        _selectedCategoryIds.remove(category.id);
      } else {
        _selectedCategoryIds.add(category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado con Título y Botón de Editar/Cancelar ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing ? 'Selecciona tus categorías' : 'Categorías preferidas',
                style: AppTextStyles.heading,
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                color: AppColors.accent1,
                onPressed: _isEditing ? _cancelEdit : _enterEditMode,
              ),
            ],
          ),
          if (!_isEditing) // Texto de ayuda solo en modo visualización
            Text(
              'Selecciona las categorías que más usas para obtener mejores recomendaciones',
              style: AppTextStyles.small,
            ),
          const SizedBox(height: 16),

          // --- Contenido Principal (Grid de Categorías) ---
          _buildCategoryGrid(),

          // --- Botón de Guardar (solo en modo edición) ---
          if (_isEditing) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.accent1,
              ),
              child: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios', style: AppTextStyles.button),
            ),
          ],
        ],
      ),
    );
  }

  // Widget helper para construir el grid
  Widget _buildCategoryGrid() {
    // Si estamos en modo edición y cargando todas las categorías
    if (_isEditing && _isLoadingAllCategories) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
    }

    // Determinamos qué lista de categorías mostrar
    final List<Category> categoriesToShow;
    if (_isEditing) {
      categoriesToShow = _allCategories;
    } else {
      // Filtramos las favoritas iniciales para mostrarlas
      // (Podríamos actualizar esto para que refleje los cambios guardados si fuera necesario)
      categoriesToShow = widget.initialFavorites;
    }

    if (categoriesToShow.isEmpty && !_isEditing) {
      return Center(child: Text('Aún no has seleccionado categorías favoritas.', style: AppTextStyles.body));
    }
     if (categoriesToShow.isEmpty && _isEditing && !_isLoadingAllCategories) {
      return Center(child: Text('No se encontraron categorías disponibles.', style: AppTextStyles.body));
    }


    // Usamos Wrap para que se ajuste automáticamente
    return Wrap(
      spacing: 12.0, // Espacio horizontal
      runSpacing: 12.0, // Espacio vertical
      children: categoriesToShow.map((category) {
        final bool isSelected = _selectedCategoryIds.contains(category.id);
        return SelectableChip( // Usamos nuestro widget reutilizable
          label: category.title,
          iconPrefix: Text(category.icon, style: const TextStyle(fontSize: 18)), // Añadimos icono
          isSelected: isSelected,
          onSelected: (_) {
            if (_isEditing) {
              _toggleSelection(category);
            }
            // En modo visualización, el tap no hace nada
          },
          // Cambiamos colores para que coincida con tu diseño
          selectedColor: AppColors.accent2,
          unselectedColor: Colors.grey.shade100,
          selectedLabelStyle: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.body.copyWith(color: AppColors.primary),
          selectedBorderColor: AppColors.accent2,
          unselectedBorderColor: Colors.grey.shade300,
        );
      }).toList(),
    );
  }
}