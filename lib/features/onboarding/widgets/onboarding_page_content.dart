import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class OnboardingPageContent extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String description;

  // 🔧 Nuevos parámetros opcionales para controlar espacios y tamaño
  final bool alignToTop;
  final double topPadding;     // espacio arriba del ícono
  final double iconRadius;
  final double iconSize;
  final double gapAfterIcon;
  final double gapAfterTitle;

  const OnboardingPageContent({
    super.key,
    required this.iconData,
    required this.title,
    required this.description,
    this.alignToTop = true,
    this.topPadding = 0,       // << lo ponemos 0 para “pegar” al logo
    this.iconRadius = 26,      // antes 30
    this.iconSize = 34,        // antes 40
    this.gapAfterIcon = 12,    // antes 30
    this.gapAfterTitle = 10,   // antes 20
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Factor de escala simple: pantallas <700 alto se compactan un poco
    final sf = (size.height / 700).clamp(0.85, 1.0);

    final effectiveIconRadius = iconRadius * sf;
    final effectiveIconSize   = iconSize * sf;
    final afterIconGap        = gapAfterIcon * sf;
    final afterTitleGap       = gapAfterTitle * sf;

    final content = Padding(
      // reduce el padding horizontal para ganar aire en pantallas chicas
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        // ⬇️ ancla arriba para que no “flote”
        mainAxisAlignment: alignToTop ? MainAxisAlignment.start : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: topPadding), // << controla la distancia al logo
          CircleAvatar(
            radius: effectiveIconRadius,
            backgroundColor: AppColors.primary.withOpacity(0.05),
            child: Icon(
              iconData,
              size: effectiveIconSize,
              color: AppColors.accent1,
            ),
          ),
          SizedBox(height: afterIconGap),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
          SizedBox(height: afterTitleGap),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );

    // Si quieres aseguras el “anclado arriba” incluso dentro de PageView/Expanded:
    return alignToTop
        ? Align(alignment: Alignment.topCenter, child: content)
        : content;
  }
}
