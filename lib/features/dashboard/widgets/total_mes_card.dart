// lib/features/dashboard/widgets/total_mes_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../budgets/models/budget_status_model.dart'; // Importa el modelo

class TotalMesCard extends StatelessWidget {
  // 1. Ahora recibe el BudgetStatus completo (puede ser null)
  final BudgetStatus? budgetStatus;

  const TotalMesCard({super.key, required this.budgetStatus});

  @override
  Widget build(BuildContext context) {
    // Valores iniciales
    double presupuesto = 0.0;
    double gastos = 0.0;
    double gastosDentroDelPresupuesto = 0.0;
    double gastoExtra = 0.0;
    double restante = 0.0;
    double chartValue = 0.0;
    bool showChart = false;

    // Calculamos los valores si hay un presupuesto activo
    if (budgetStatus != null) {
      presupuesto = budgetStatus!.totalIncome;
      gastos = budgetStatus!.totalSpent;
      showChart = true;

      // --- LÓGICA NUEVA ---
      // Gasto que se muestra como "Gastado" (limitado al presupuesto)
      gastosDentroDelPresupuesto = min(gastos, presupuesto);
      // Gasto que excedió el presupuesto
      gastoExtra = max(0, gastos - presupuesto);
      // El restante nunca es negativo
      restante = max(0, presupuesto - gastos);
      // El valor del gráfico se limita a 100%
      chartValue = presupuesto > 0
          ? (gastos / presupuesto * 100).clamp(0, 100)
          : 0.0;
      // --- FIN LÓGICA NUEVA ---
    }

    print(
      "DEBUG WIDGET: TotalMesCard using gastos: $gastos, presupuesto: $presupuesto, extra: $gastoExtra",
    );

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
          Text(
            'Resumen del Presupuesto',
            style: AppTextStyles.heading,
          ), // Título actualizado
          const SizedBox(height: 24),
          _buildSummaryRow(
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.blue.shade700,
            label: 'Presupuesto',
            amount: presupuesto.toStringAsFixed(0),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            icon: Icons.arrow_downward,
            color: Colors.orange.shade700,
            label: 'Gastado',
            amount: gastosDentroDelPresupuesto.toStringAsFixed(0),
          ), // Label actualizado
          // --- NUEVA FILA CONDICIONAL ---
          // Solo muestra "Gasto Extra" si es mayor que cero
          if (gastoExtra > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              label: 'Gasto Extra',
              amount: gastoExtra.toStringAsFixed(0),
            ),
          ],
          // --- FIN NUEVA FILA ---
          const Divider(height: 32),
          _buildSummaryRow(
            label: 'Restante',
            amount: restante.toStringAsFixed(0),
            isBalance: true,
          ), // Label actualizado
          const SizedBox(height: 24),

          // --- 4. Mostramos el gráfico O un mensaje ---
          if (showChart) ...[
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // Muestra 100% si se excedió
                        '${min(chartValue, 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text('Gastado', style: AppTextStyles.small),
                    ],
                  ),
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 4,
                      centerSpaceRadius: 55,
                      sections: [
                        PieChartSectionData(
                          value: min(
                            chartValue,
                            100,
                          ), // Gasto real vs presupuesto
                          color: AppColors.element,
                          radius: 15,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          // El valor restante visual también se ajusta
                          value: max(0, 100 - chartValue),
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
            Row(
              // Leyenda
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  AppColors.element,
                  'Gastado',
                ), // Label actualizado
                const SizedBox(width: 24),
                _buildLegendItem(
                  AppColors.element.withOpacity(0.2),
                  'Restante',
                ), // Label actualizado
              ],
            ),
          ] else ...[
            // Mensaje si no hay presupuesto activo
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'Establece un presupuesto para ver tu progreso aquí.',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.small),
      ],
    );
  }
}
