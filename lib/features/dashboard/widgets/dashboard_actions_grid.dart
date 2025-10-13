// lib/features/dashboard/widgets/dashboard_actions_grid.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';

class DashboardActionsGrid extends StatelessWidget {
  const DashboardActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true, // Para que el GridView no ocupe espacio infinito
      physics: const NeverScrollableScrollPhysics(), // Para que no haga scroll por sí mismo
      children: [
        _buildActionCard(
          icon: Icons.star_outline,
          title: 'Recomendaciones',
          subtitle: '3 nuevas',
          showBadge: true,
        ),
        _buildActionCard(
          icon: Icons.library_books_outlined,
          title: 'Aprender',
          subtitle: 'Microcontenidos',
        ),
        _buildActionCard(
          icon: Icons.refresh,
          title: 'Actualizar análisis',
        ),
        _buildActionCard(
          icon: Icons.visibility_outlined,
          title: 'Ver...', // Placeholder
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, String? subtitle, bool showBadge = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black12,
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
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
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
                child: Text('3', style: AppTextStyles.small.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}