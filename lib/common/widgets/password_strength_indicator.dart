import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    // Calculamos qué reglas se cumplen
    bool hasMinLength = password.length >= 8;
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // Contamos cuántas reglas se cumplen (0 a 3)
    int strength = 0;
    if (hasMinLength) strength++;
    if (hasNumber) strength++;
    if (hasSpecialChar) strength++;

    // Definimos el color según el nivel
    Color strengthColor = Colors.grey.shade300;
    String label = "Muy corta";

    if (strength == 1) {
      strengthColor = Colors.red;
      label = "Débil";
    } else if (strength == 2) {
      strengthColor = Colors.orange;
      label = "Media";
    } else if (strength == 3) {
      strengthColor = Colors.green;
      label = "¡Segura!";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 5,
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: strength == 0 ? Colors.grey : strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
