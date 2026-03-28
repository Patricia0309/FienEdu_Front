import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../analysis/models/profile_response_model.dart';

class PerfilFinancieroCard extends StatelessWidget {
  final ProfileResponse? profileData;

  const PerfilFinancieroCard({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, mostramos un cargando simple
    if (profileData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si está calculando (Usuario Nuevo)
    if (profileData!.isCalculating) {
      return _buildNewUserCard();
    }

    // Si ya tiene perfil (Usuario con Perfil Asignado)
    return _buildAssignedProfileCard();
  }

  // --- DISEÑO PARA USUARIO NUEVO (Basado en tu imagen) ---
  Widget _buildNewUserCard() {
    double progress = profileData!.currentCount / profileData!.goal;
    int percentage = (progress * 100).toInt();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Completa tu perfil!',
              style: AppTextStyles.subtitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega al menos ${profileData!.goal} transacciones para generar tu análisis financiero personalizado',
              style: AppTextStyles.body.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${profileData!.currentCount} / ${profileData!.goal} transacciones',
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade100,
                color: AppColors.primary,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinea el texto a la izquierda
              children: [
                // Primera línea: El porcentaje
                Text(
                  '$percentage% completado',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ), // Pequeño espacio entre las dos líneas
                // Segunda línea: Lo que falta
                Text(
                  'Faltan ${profileData!.goal - profileData!.currentCount} transacciones',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // La tarjetita amarilla de abajo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4).withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Agrega tus gastos e ingresos recientes para obtener recomendaciones personalizadas',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DISEÑO PARA PERFIL ASIGNADO ---
  Widget _buildAssignedProfileCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perfil financiero',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.psychology_outlined, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent2.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                profileData!.profile,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profileData!.justification,
              style: AppTextStyles.body.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
