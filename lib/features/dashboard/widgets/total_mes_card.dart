// lib/features/dashboard/widgets/total_mes_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math'; // Para min y max
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
// Ya no necesita BudgetStatus, solo los números

class TotalMesCard extends StatelessWidget {
  // 1. Vuelve a recibir números simples
  final double presupuestoTotal;
  final double totalGastos;

  const TotalMesCard({
    super.key,
    required this.presupuestoTotal,
    required this.totalGastos,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Toda la lógica de cálculo ahora vive aquí
    final double gastos = totalGastos;
    final double presupuesto = presupuestoTotal;

    final double gastosDentroDelPresupuesto = min(gastos, presupuesto);
    final double gastoExtra = max(0, gastos - presupuesto);
    final double restante = max(0, presupuesto - gastos);
    // clamp(0.0, 1.0) asegura que el porcentaje nunca sea < 0 o > 1
    final double porcentajeGasto = presupuesto > 0
        ? (gastos / presupuesto).clamp(0.0, 1.0)
        : 0.0;
    final double chartValue = porcentajeGasto * 100;

    final bool showChart = presupuesto > 0;

    print(
      "DEBUG WIDGET: TotalMesCard CONSTRUIDO con gastos: $gastos, presupuesto: $presupuesto, extra: $gastoExtra",
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
          Text('Resumen del presupuesto', style: AppTextStyles.heading),
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
          ),

          if (gastoExtra > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              label: 'Gasto extra',
              amount: gastoExtra.toStringAsFixed(0),
            ),
          ],

          const Divider(height: 32),
          _buildSummaryRow(
            label: 'Restante',
            amount: restante.toStringAsFixed(0),
            isBalance: true,
          ),
          const SizedBox(height: 24),

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
                        '${chartValue.toStringAsFixed(0)}%', // Se limita a 100 visualmente por la lógica del PieChart
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
                          value:
                              chartValue, // El valor visual se basa en el porcentaje
                          color: AppColors.element,
                          radius: 15,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (100 - chartValue).clamp(
                            0,
                            100,
                          ), // Lo que queda
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.element, 'Gastado'),
                const SizedBox(width: 24),
                _buildLegendItem(
                  AppColors.element.withOpacity(0.2),
                  'Restante',
                ),
              ],
            ),
          ] else ...[
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
