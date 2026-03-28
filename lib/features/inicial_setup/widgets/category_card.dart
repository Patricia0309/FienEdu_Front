import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // <-- 1. IMPORTA EL NUEVO PAQUETE
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected ? AppColors.accent3.withOpacity(0.5) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.accent2 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 2. Quitamos el SingleChildScrollView de aquí
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // 3. Reemplazamos Text con AutoSizeText
                  AutoSizeText(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Permite que el texto ocupe hasta 2 líneas
                    minFontSize:
                        12, // Evita que el texto se haga demasiado pequeño
                    overflow: TextOverflow
                        .ellipsis, // Si no cabe en 2 líneas, pone "..."
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: onInfoTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
