// lib/features/analysis/widgets/tendencia_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/budget_tendency_model.dart';

class TendenciaCard extends StatelessWidget {
  final BudgetTendency tendencyData;

  const TendenciaCard({super.key, required this.tendencyData});

  @override
  Widget build(BuildContext context) {
    // --- Tu lógica (está perfecta) ---
    final bool isUp = tendencyData.direction == 'increase';
    final String arrow = isUp ? '↑' : '↓';
    final Color color = isUp
        ? Colors.red
        : Colors.green; // Gasto 'arriba' es malo (rojo)
    final IconData icon = isUp ? Icons.trending_up : Icons.trending_down;

    // --- ¡AQUÍ ESTÁ EL ARREGLO! ---
    // Copiamos el Container de tu ejemplo
    return Container(
      padding: const EdgeInsets.all(20.0), // <-- AÑADIDO
      decoration: BoxDecoration(
        // <-- AÑADIDO
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
      child: Row(
        // Tu Row original va dentro
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tendencia', style: AppTextStyles.heading),
                Text(
                  '$arrow ${tendencyData.percentageChange.abs().toStringAsFixed(0)}%',
                  style: AppTextStyles.subtitle.copyWith(color: color),
                ),
                Text(
                  // Usamos el 'message' de la API en lugar de construirlo aquí
                  tendencyData.message,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
