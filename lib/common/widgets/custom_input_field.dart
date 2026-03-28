// lib/common/widgets/custom_input_field.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final int? maxLines;

  // --- 1. AÑADIMOS EL NUEVO PARÁMETRO DE VALIDACIÓN ---
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.prefixIcon,
    this.maxLines = 1,
    this.validator, // <-- 2. LO AÑADIMOS AL CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    // Cambiamos a TextFormField para poder usar el validador
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator, // <-- 3. USAMOS EL VALIDADOR AQUÍ
      style: AppTextStyles.body.copyWith(color: AppColors.primary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.body,
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.secondary.withOpacity(0.5),
        ),

        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.secondary.withOpacity(0.8))
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.secondary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent1, width: 2.0),
        ),
        // Bordes para cuando hay un error de validación
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
        ),
      ),
    );
  }
}
