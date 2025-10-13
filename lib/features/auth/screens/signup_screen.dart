import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/theme/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _navigateToProfileSetup() {
    Navigator.pushNamed(
      context,
      AppRoutes.profileSetup,
      arguments: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // --- ESTA ES LA ESTRUCTURA CORRECTA Y ROBUSTA ---
          child: Column(
            children: [
              // --- 1. La sección que se desliza (scroll) ---
              Expanded(
                // Expanded le da a SingleChildScrollView un tamaño finito para trabajar
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Aquí está todo tu contenido sin cambios ---
                      SvgPicture.asset('assets/img/svg/Logo.svg', height: 220),
                      const SizedBox(height: 24),
                      Text(
                        'Crea tu cuenta',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registrate para comenzar tu viaje hacia la educación financiera.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 24),
                      CustomInputField(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        labelText: 'Contraseña',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                      ),
                    ],
                  ),
                ),
              ),
              // --- 2. La sección del botón (fija abajo) ---
              // El botón está fuera del scroll, por lo que siempre está visible.
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Continuar',
                onPressed: _navigateToProfileSetup,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
