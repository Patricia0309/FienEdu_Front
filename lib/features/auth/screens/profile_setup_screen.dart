import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../data/services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _aliasController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleSignUp() async {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final email = arguments['email']!;
    final password = arguments['password']!;
    final displayName = _aliasController.text;

    // TODO: Añadir validación (ej: que el alias no esté vacío)

    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.initialSetup,
          (route) => false,
        );
      }
    } catch (e) {
      // TODO: Mostrar el error al usuario con un SnackBar
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Regresar',
          style: AppTextStyles.body.copyWith(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // --- ESTRUCTURA PRINCIPAL CORRECTA ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- ÁREA DE SCROLL ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Tu contenido (sin cambios) ---
                      SvgPicture.asset('assets/img/svg/Logo.svg', height: 220),
                      const SizedBox(height: 40),
                      Text(
                        '¿Cómo quieres que te llame FinEdu?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elige un nombre o alias que usaras en la app',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 40),
                      CustomInputField(
                        labelText: 'Nombre o Alias',
                        hintText: 'Ej: Alex, María, Charlie...',
                        prefixIcon: Icons.person_outline,
                        controller: _aliasController,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Este nombre aparecerá en tu perfil',
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ),
              // --- BOTÓN FIJO ABAJO ---
              const SizedBox(height: 20),
              PrimaryButton(
                text: _isLoading ? 'Finalizando...' : 'Continuar',
                onPressed: _isLoading ? null : _handleSignUp,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
