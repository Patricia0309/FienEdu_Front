import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../budgets/models/income_period_history_model.dart';

class BudgetHistoryRow extends StatelessWidget {
  final IncomePeriodHistory budget;
  final VoidCallback onDelete;

  const BudgetHistoryRow({
    super.key,
    required this.budget,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos el porcentaje
    final double percentage = budget.totalIncome > 0
        ? (budget.totalSpent / budget.totalIncome) * 100
        : 0;

    // Valor para la barra (de 0.0 a 1.0)
    final double barValue = (budget.totalSpent / budget.totalIncome).clamp(
      0.0,
      1.0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormat('dd MMM yy').format(budget.startDate)} - ${DateFormat('dd MMM yy').format(budget.endDate)}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${budget.totalSpent.toStringAsFixed(0)} de \$${budget.totalIncome.toStringAsFixed(0)}",
                style: AppTextStyles.small.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              // --- AQUÍ SE MUESTRA EL PORCENTAJE ---
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: AppTextStyles.small.copyWith(
                  fontWeight: FontWeight.bold,
                  color: percentage > 100 ? Colors.red : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: barValue,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: percentage > 100 ? Colors.red : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
