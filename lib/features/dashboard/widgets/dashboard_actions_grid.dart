// lib/features/dashboard/widgets/dashboard_actions_grid.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';
// 1. Importa la nueva pantalla
import '../../recommendations/screens/recommendations_screen.dart';

class DashboardActionsGrid extends StatelessWidget {
  // 2. Acepta el conteo
  final int recommendationCount;

  const DashboardActionsGrid({
    super.key,
    this.recommendationCount = 0, // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    // 3. Define la función de navegación
    void navigateToRecommendations() {
      // (Asegúrate de tener RecommendationsScreen.routeName en tu router principal)
      // Navigator.pushNamed(context, RecommendationsScreen.routeName);

      // O si no usas rutas con nombre (más simple por ahora):
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecommendationsScreen()),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          context: context, // Pasa el context
          icon: Icons.star_outline,
          title: 'Recomendaciones',
          // 4. Usa el conteo dinámico
          subtitle: '$recommendationCount nuevas',
          showBadge: recommendationCount > 0, // Muestra solo si hay
          badgeCount: recommendationCount,
          onTap: navigateToRecommendations, // 5. Asigna la función de tap
        ),
        _buildActionCard(
          context: context,
          icon: Icons.library_books_outlined,
          title: 'Aprender',
          subtitle: 'Contenidos',
          onTap: () {
            // TODO: Navegar a la pantalla de Aprender
            print("Navegar a Aprender");
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context, // Necesita el context
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    int badgeCount = 0,
    VoidCallback? onTap, // 6. Acepta un callback
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black12,
      // 7. Envuelve en InkWell para el efecto de tap
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.grey.shade700),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.small),
                  ],
                ],
              ),
            ),
            if (showBadge)
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    // 8. Muestra el conteo dinámico
                    badgeCount.toString(),
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
