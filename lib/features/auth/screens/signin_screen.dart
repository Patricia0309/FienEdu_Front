import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../data/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // --- 1. Añadimos los controladores ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // --- 2. Usamos los controladores para obtener el texto ---
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } catch (e) {
      print(e);
      // TODO: Mostrar un SnackBar con el error al usuario
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. Limpiamos los controladores ---
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/img/svg/Logo.svg', height: 220),
                      const SizedBox(height: 24),
                      Text(
                        'Iniciar sesión',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa a tu cuenta para continuar',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 24),
                      CustomInputField(
                        prefixIcon: Icons.email_outlined,
                        labelText: 'Correo electrónico',
                        controller:
                            _emailController, // <-- 4. Asignamos el controller
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        prefixIcon: Icons.lock_outline,
                        labelText: 'Contraseña',
                        obscureText: true,
                        controller:
                            _passwordController, // <-- 4. Asignamos el controller
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: _isLoading ? 'Iniciando...' : 'Iniciar sesión',
                onPressed: _isLoading ? null : _handleSignIn,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
