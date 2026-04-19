import 'package:FinEdu/common/theme/app_colors.dart';
import 'package:FinEdu/common/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _service = AuthService();
  bool _isLoading = false;

  void _sendCode() async {
    setState(() => _isLoading = true);
    bool success = await _service.recoverPassword(_emailController.text.trim());
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al enviar código")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recuperar cuenta"),
        titleTextStyle: AppTextStyles.heading,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.lock_reset, size: 100, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              "Ingresa tu email registrado en FinEdu",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendCode,
                    child: Text("Enviar Código"),
                  ),
          ],
        ),
      ),
    );
  }
}
