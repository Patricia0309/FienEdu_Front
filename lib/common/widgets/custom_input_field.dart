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
  
  // --- CAMBIOS AQUÍ ---
  final IconData? prefixIcon; // 1. Nos aseguramos de que sea opcional con '?'
  final int? maxLines;         // 2. Añadimos el nuevo parámetro 'maxLines'

  const CustomInputField({
    super.key,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.prefixIcon,       // <-- Sin 'required'
    this.maxLines = 1,       // <-- Le damos un valor por defecto de 1
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines, // <-- 3. Usamos el nuevo parámetro aquí
      style: AppTextStyles.body.copyWith(color: AppColors.primary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.body,
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.secondary.withOpacity(0.5)),
        
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: AppColors.secondary.withOpacity(0.8)) 
            : null,
            
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent1, width: 2.0),
        ),
      ),
    );
  }
}