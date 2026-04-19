import 'package:FinEdu/common/theme/app_colors.dart';
import 'package:FinEdu/common/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email, code;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  final _service = AuthService();

  // 👁️ Estado para mostrar/ocultar contraseña
  bool _obscurePassword = true;

  // Lógica de reset
  void _reset() async {
    // Solo permitimos reset si cumple las condiciones básicas
    if (_passController.text.length < 8) return;

    bool success = await _service.resetPassword(
      widget.email,
      widget.code,
      _passController.text,
    );
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "¡Contraseña actualizada! Usa tu nueva clave para entrar.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validaciones en tiempo real
    bool hasEightChars = _passController.text.length >= 8;
    bool hasNumberOrSymbol = _passController.text.contains(
      RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7EE), // Tu color beige
      appBar: AppBar(
        title: const Text("Nueva contraseña"),
        titleTextStyle: AppTextStyles.subtitle.copyWith(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Crea una nueva contraseña segura para tu cuenta.",
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 32),

            // --- Campo de contraseña con ojito ---
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              onChanged: (value) =>
                  setState(() {}), // Para actualizar los checks
              decoration: InputDecoration(
                labelText: "Nueva Contraseña",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
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

            const SizedBox(height: 20),

            // --- Validación Visual ---
            Text(
              "Tu contraseña debe tener:",
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildValidationRow("Mínimo 8 caracteres", hasEightChars),
            const SizedBox(height: 8),
            _buildValidationRow("Un número o símbolo", hasNumberOrSymbol),

            const SizedBox(height: 40),

            // --- Botón de Restablecer ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Se deshabilita si no cumple requisitos
                  elevation: (hasEightChars && hasNumberOrSymbol) ? 2 : 0,
                ),
                onPressed: (hasEightChars && hasNumberOrSymbol) ? _reset : null,
                child: const Text(
                  "Restablecer Contraseña",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las filas de validación
  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.grey,
            fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
