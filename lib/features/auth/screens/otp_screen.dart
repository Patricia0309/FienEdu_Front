import 'package:FinEdu/common/theme/app_colors.dart';
import 'package:FinEdu/common/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatelessWidget {
  final String email;
  OTPScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verificar código"),
        titleTextStyle: AppTextStyles.heading,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text("Revisa tu correo: \n$email", textAlign: TextAlign.center),
              SizedBox(height: 30),
              Pinput(
                length: 6,
                onCompleted: (pin) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResetPasswordScreen(email: email, code: pin),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
