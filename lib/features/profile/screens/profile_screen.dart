// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../models/student_model.dart';
import '../widgets/user_info_card.dart';
import '../widgets/favorite_categories_section.dart'; // Asegúrate que la ruta sea correcta

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  // Variables para guardar el estado de la pantalla
  Student? _studentData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos del perfil al iniciar la pantalla
    _loadProfileData();
  }

  // Función para cargar o recargar los datos del perfil
  Future<void> _loadProfileData() async {
    // Ponemos en estado de carga solo si aún no tenemos datos
    // o si ya estamos mostrando datos (para indicar un refresco)
    if (_studentData == null || !_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null; // Limpia errores previos al reintentar
      });
    }
    try {
      final student = await _userService.getMe();
      if (mounted) { // Verifica si el widget todavía está en pantalla
        setState(() {
          _studentData = student;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // Función para manejar el cierre de sesión
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cierre de Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _authService.logout();
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color de fondo general de la app (el blanco roto/crema más claro)
      backgroundColor: AppColors.background,
      // Construimos el cuerpo basado en el estado actual
      body: _buildBody(),
    );
  }

  // Widget helper para construir el cuerpo según el estado
  Widget _buildBody() {
    // --- ESTADO DE CARGA ---
    if (_isLoading) {
      // Muestra un spinner si está cargando Y aún no tiene datos previos
      // Si ya tiene datos (_studentData != null), muestra los datos antiguos mientras recarga
      return _studentData == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(_studentData!); // Muestra contenido antiguo mientras recarga
    }

    // --- ESTADO DE ERROR ---
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error al cargar el perfil: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: _loadProfileData,
              )
            ],
          ),
        ),
      );
    }

    // --- ESTADO DE ÉXITO (Tenemos datos) ---
    if (_studentData != null) {
      return _buildProfileContent(_studentData!);
    }

    // Estado por defecto (no debería ocurrir si la lógica es correcta)
    return const Center(child: Text('No se pudo cargar la información del perfil.'));
  }

  // Widget helper para construir el contenido principal del perfil
  Widget _buildProfileContent(Student student) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- 1. Encabezado ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 80), // Más padding abajo para el overlap
            decoration: const BoxDecoration(
              color: AppColors.element, // Color del header
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(
                    'assets/img/svg/Logo.2.svg', // Asegúrate que la ruta sea correcta
                    height: 45,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Mi Perfil', style: AppTextStyles.title.copyWith(color: AppColors.primary)),
                Text(
                  'Gestiona tu cuenta',
                  style: AppTextStyles.body.copyWith(color: AppColors.primary.withOpacity(0.7)),
                ),
              ],
            ),
          ),

          // --- Contenido Principal (con Padding y overlap) ---
          Transform.translate(
            offset: const Offset(0, -50), // Sube todo el contenido inferior
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // --- 2. Tarjeta de Información Personal ---
                  UserInfoCard(student: student), // Usa el widget actualizado
                  const SizedBox(height: 24), // Espacio entre tarjetas

                  // --- 3. Tarjeta de Categorías ---
                  FavoriteCategoriesSection(
                    key: ValueKey(student.favoriteCategories.hashCode), // Para forzar reconstrucción
                    initialFavorites: student.favoriteCategories,
                    onSaveSuccess: _loadProfileData, // Pasa la función de recarga
                  ),
                  const SizedBox(height: 30),

                  // --- 4. Botón de Cierre de Sesión ---
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text('Cerrar sesión', style: AppTextStyles.button),
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 30), // Espacio al final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} // Fin de la clase _ProfileScreenState