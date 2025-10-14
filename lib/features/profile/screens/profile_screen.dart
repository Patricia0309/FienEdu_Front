import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../models/student_model.dart';
import '../widgets/user_info_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  late Future<Student> _studentFuture;

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla, pedimos los datos del usuario
    _studentFuture = _userService.getMe();
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      // Navega a la pantalla de bienvenida y elimina todas las pantallas anteriores
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Student>(
        future: _studentFuture,
        builder: (context, snapshot) {
          // --- ESTADO DE CARGA ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- ESTADO DE ERROR ---
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar el perfil: ${snapshot.error}'),
            );
          }
          // --- ESTADO DE ÉXITO ---
          if (snapshot.hasData) {
            final student = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // --- Encabezado ---
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            color: AppColors.accent2,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(40),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: SvgPicture.asset(
                                  'assets/img/svg/Logo.2.svg',
                                  height: 60,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Mi Perfil',
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Tarjeta de Información Personal (con datos reales) ---
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: UserInfoCard(
                      student: student,
                    ), // Pasamos el objeto student
                  ),

                  // --- Tarjeta de Categorías ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categorías seleccionadas',
                            style: AppTextStyles.heading,
                          ),
                          const SizedBox(height: 16),
                          // TODO: Mostrar aquí las categorías favoritas del usuario
                          const Text(
                            'Aquí irá el grid con tus categorías favoritas...',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Botón de Cerrar Sesión ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text('Cerrar sesión', style: AppTextStyles.button),
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
          // Estado por defecto
          return const Center(
            child: Text('No se pudo cargar la información del perfil.'),
          );
        },
      ),
    );
  }
}
