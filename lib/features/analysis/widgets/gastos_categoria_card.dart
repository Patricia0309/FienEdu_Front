// lib/features/analysis/widgets/gastos_categoria_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class GastosCategoriaCard extends StatelessWidget {
  const GastosCategoriaCard({super.key});

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
          Text('Gastos por categoría', style: AppTextStyles.heading),
          Text('Últimos 30 días', style: AppTextStyles.small),
          const SizedBox(height: 20),
          _buildCategoryRow('Alimentación', 2500, 0.29, AppColors.accent1),
          const SizedBox(height: 16),
          _buildCategoryRow('Transporte', 1800, 0.21, AppColors.accent2),
          const SizedBox(height: 16),
          _buildCategoryRow('Entretenimiento', 1500, 0.18, AppColors.accent2),
          // Puedes añadir más filas aquí
        ],
      ),
    );
  }

  // Widget helper para cada fila de categoría
  Widget _buildCategoryRow(
    String category,
    double amount,
    double percentage,
    Color barColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: AppTextStyles.body),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  color: barColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ],
    );
  }
}
