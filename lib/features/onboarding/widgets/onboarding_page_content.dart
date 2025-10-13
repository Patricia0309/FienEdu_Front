import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart'; 
import '../../../common/theme/app_text_styles.dart';

class OnboardingPageContent extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String description;

  const OnboardingPageContent({
    super.key,
    required this.iconData,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.primary.withOpacity(0.05),
            child: Icon(
              iconData, // <-- USA EL ÍCONO RECIBIDO
              size: 70,
              color: AppColors.accent1, // Usa un color de acento
            ),
          ),
          const SizedBox(height: 50),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.subtitle),
          const SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center, style: AppTextStyles.body),
        ],
      ),
    );
  }
}