// lib/features/analysis/widgets/tendencia_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';

class TendenciaCard extends StatelessWidget {
  const TendenciaCard({super.key});

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
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Colors.red, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tendencia', style: AppTextStyles.heading),
                Text(
                  '↑ 5%',
                  style: AppTextStyles.subtitle.copyWith(color: Colors.red),
                ),
                Text(
                  'Tus gastos aumentaron 5% respecto al mes anterior',
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
