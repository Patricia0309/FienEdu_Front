import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/student_model.dart';

class UserInfoCard extends StatelessWidget {
  final Student student;

  const UserInfoCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información personal',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 16),

          // Nombre
          TextFormField(
            initialValue: student.displayName ?? 'Sin nombre',
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Nombre',
              labelStyle: AppTextStyles.body.copyWith(
                color: AppColors.primary.withOpacity(0.7),
              ),
              prefixIcon: const Icon(Icons.person_outline),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Correo
          TextFormField(
            initialValue: student.email ?? 'Sin correo',
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: AppTextStyles.body.copyWith(
                color: AppColors.primary.withOpacity(0.7),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
