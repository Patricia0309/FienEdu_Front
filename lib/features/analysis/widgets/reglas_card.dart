// lib/features/analysis/widgets/reglas_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';

class ReglasCard extends StatelessWidget {
  const ReglasCard({super.key});

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
          Row(
            children: [
              const Icon(Icons.rule, size: 24),
              const SizedBox(width: 12),
              Text('Reglas identificadas', style: AppTextStyles.heading),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleRow(
            'Gastas más del 40% de tus ingresos en necesidades básicas (óptimo)',
          ),
          const SizedBox(height: 12),
          _buildRuleRow(
            'Tu gasto en entretenimiento está en el 18% (recomendado: 15-20%)',
          ),
          const SizedBox(height: 12),
          _buildRuleRow(
            'Tienes potencial para ahorrar 15% más si reduces gastos variables',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
