import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    required IconData prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextStyles.body.copyWith(color: AppColors.primary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.body,
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.secondary.withOpacity(0.5),
        ),

        // Estilo del borde cuando no está seleccionado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.secondary.withOpacity(0.5),
            width: 1.5,
          ),
        ),

        // Estilo del borde cuando está seleccionado (en foco)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent1, width: 2.0),
        ),
      ),
    );
  }
}
