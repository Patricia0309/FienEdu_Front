import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/password_strength_indicator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// 👁️‍🗨️ Estado local para mostrar/ocultar la contraseña
  bool _obscurePassword = true;

  bool _isPasswordSecure() {
    final pass = _passwordController.text;

    // Regla 1: Mínimo 8 caracteres
    bool hasMinLength = pass.length >= 8;

    // Regla 2: Al menos un número (Regex \d como en tu Python)
    bool hasNumber = RegExp(r'\d').hasMatch(pass);

    // Regla 3: Al menos un carácter especial (Igual que tu backend)
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?:{}|<>]').hasMatch(pass);

    return hasMinLength && hasNumber && hasSpecialChar;
  }

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
          child: Column(
            children: [
              // --- 1. Sección desplazable ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/img/svg/Logo.svg', height: 220),
                      const SizedBox(height: 24),
                      Text(
                        'Crea tu cuenta',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Regístrate para comenzar tu viaje hacia la educación financiera.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 24),

                      // --- Campo de correo ---
                      CustomInputField(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // --- Campo de contraseña con ojito 👁️ ---
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PasswordStrengthIndicator(
                        password: _passwordController.text,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'La contraseña debe tener al menos 8 caracteres, incluyendo un número y un símbolo (!@#\$%^&*).',
                        style: AppTextStyles.small.copyWith(
                          color: _isPasswordSecure()
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. Botón inferior fijo ---
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Continuar',
                onPressed: _isPasswordSecure() ? _navigateToProfileSetup : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
