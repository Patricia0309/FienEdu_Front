// lib/features/dashboard/widgets/total_mes_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../budgets/models/budget_status_model.dart'; // Importa el modelo

class TotalMesCard extends StatelessWidget {
  // 1. Ahora recibe el BudgetStatus completo (puede ser null)
  final BudgetStatus? budgetStatus;

  const TotalMesCard({
    super.key,
    required this.budgetStatus,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Determinamos los valores basados en si hay un presupuesto activo
    final double presupuesto = budgetStatus?.totalIncome ?? 0.0;
    final double gastos = budgetStatus?.totalSpent ?? 0.0;
    final double balance = presupuesto - gastos;
    final double porcentajeGasto = presupuesto > 0 ? (gastos / presupuesto).clamp(0.0, 1.0) : 0.0;
    final double chartValue = porcentajeGasto * 100;

    print("DEBUG WIDGET: TotalMesCard using gastos: $gastos");

    // 3. Determinamos si mostrar el gráfico o un mensaje
    final bool showChart = budgetStatus != null;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen del Presupuesto', style: AppTextStyles.heading), // Título actualizado
          const SizedBox(height: 24),
          _buildSummaryRow(icon: Icons.account_balance_wallet_outlined, color: Colors.blue.shade700, label: 'Presupuesto', amount: presupuesto.toStringAsFixed(0)),
          const SizedBox(height: 12),
          _buildSummaryRow(icon: Icons.arrow_downward, color: Colors.red.shade600, label: 'Gastado', amount: gastos.toStringAsFixed(0)), // Label actualizado
          const Divider(height: 32),
          _buildSummaryRow(label: 'Restante', amount: balance.toStringAsFixed(0), isBalance: true), // Label actualizado
          const SizedBox(height: 24),

          // --- 4. Mostramos el gráfico O un mensaje ---
          if (showChart) ...[
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column( /* ... Texto del centro sin cambios ... */ ),
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 4,
                      centerSpaceRadius: 55,
                      sections: [
                        PieChartSectionData(
                          value: chartValue, // Gasto real vs presupuesto
                          color: AppColors.element,
                          radius: 15,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (100 - chartValue).clamp(0, 100), // Lo que queda
                          color: AppColors.element.withOpacity(0.2),
                          radius: 15,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row( // Leyenda
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 _buildLegendItem(AppColors.element, 'Gastado'), // Label actualizado
                 const SizedBox(width: 24),
                 _buildLegendItem(AppColors.element.withOpacity(0.2), 'Restante'), // Label actualizado
               ],
            )
          ] else ...[
            // Mensaje si no hay presupuesto activo
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'Establece un presupuesto para ver tu progreso aquí.',
                  style: AppTextStyles.body.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    IconData? icon,
    Color? color,
    required String label,
    required String amount,
    bool isBalance = false,
  }) {
    final amountStyle = AppTextStyles.body.copyWith(
      fontWeight: FontWeight.bold,
      color: color ?? AppColors.primary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: isBalance
                  ? AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyles.body,
            ),
          ],
        ),
        Text('\$$amount', style: amountStyle),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.small),
      ],
    );
  }
}