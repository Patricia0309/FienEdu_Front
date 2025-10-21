import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';
import '../models/student_model.dart';
import '../widgets/user_info_card.dart'; // Make sure this path is correct

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
    _studentFuture = _userService.getMe();
  }

  void _handleLogout() async {
    // Show confirmation dialog before logging out
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cierre de Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false), // Return false if cancelled
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true), // Return true if confirmed
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    // Only logout if the user confirmed
    if (confirmed == true && mounted) {
      await _authService.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the general in-app background color defined in MainScreen
    // The Scaffold background here should be transparent if MainScreen sets the color
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Student>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar el perfil: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            final student = snapshot.data!;
            // Use SingleChildScrollView > Column for the main structure
            return SingleChildScrollView(
              child: Column(
                children: [
                  // --- 1. Fixed Header ---
                  Container(
                    width: double.infinity, // Take full width
                    padding: const EdgeInsets.only(
                      top: 60,
                      bottom: 60,
                    ), // Adjust padding as needed
                    decoration: const BoxDecoration(
                      color: AppColors.accent2, // Your desired header color
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: SvgPicture.asset(
                            'assets/img/svg/Logo.2.svg', // Ensure path is correct
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mi Perfil',
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Gestiona tu cuenta',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- 2. Overlapping User Info Card ---
                  Transform.translate(
                    offset: const Offset(0, -50), // Pulls the card up
                    child: UserInfoCard(student: student),
                  ),

                  // --- 3. Categories Card (with some negative margin if needed) ---
                  Padding(
                    // Adjusted horizontal padding, no top padding needed due to overlap
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
                          // TODO: Display user's favorite categories grid here
                          const Text(
                            'Aquí irá el grid con tus categorías favoritas...',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 4. Logout Button ---
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
                  const SizedBox(height: 30), // Bottom spacing
                ],
              ),
            );
          }
          return const Center(
            child: Text('No se pudo cargar la información del perfil.'),
          );
        },
      ),
    );
  }
}
