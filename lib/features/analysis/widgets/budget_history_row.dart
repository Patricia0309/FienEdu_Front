// lib/features/analysis/widgets/budget_history_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/income_period_history_model.dart';

class BudgetHistoryRow extends StatelessWidget {
  final IncomePeriodHistory budget;

  const BudgetHistoryRow({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    // Calculamos el porcentaje, permitiendo que sea > 100%
    final double percentageSpent = (budget.totalIncome > 0) 
        ? (budget.totalSpent / budget.totalIncome) 
        : 0;
    
    // El gasto extra es cualquier gasto por encima del 100%
    final double extraSpent = (budget.totalSpent > budget.totalIncome)
        ? budget.totalSpent - budget.totalIncome
        : 0;

    // Para la barra de progreso, el valor debe estar entre 0 y 1
    final double progressBarValue = percentageSpent.clamp(0.0, 1.0);
    
    // Formateamos las fechas
    final formatter = DateFormat('d MMM');
    final String periodTitle = '${formatter.format(budget.startDate)} - ${formatter.format(budget.endDate)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: Título (Fechas) y Monto del Presupuesto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(periodTitle, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'Presupuesto: \$${budget.totalIncome.toStringAsFixed(0)}',
                style: AppTextStyles.body.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fila 2: Barra de Progreso y Porcentaje
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressBarValue,
                    minHeight: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    // Si se pasó, la barra se pone roja
                    color: extraSpent > 0 ? Colors.red.shade400 : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(percentageSpent * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: extraSpent > 0 ? Colors.red.shade400 : AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fila 3: Gasto Extra (Condicional)
          if (extraSpent > 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Gasto Extra: \$${extraSpent.toStringAsFixed(0)}',
                style: AppTextStyles.small.copyWith(color: Colors.red.shade600, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}