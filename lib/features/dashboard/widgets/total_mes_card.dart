// lib/features/dashboard/widgets/total_mes_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class TotalMesCard extends StatelessWidget {
  // 1. Recibimos el presupuesto total, además de los gastos
  final double presupuestoTotal;
  final double totalGastos;

  const TotalMesCard({
    super.key,
    required this.presupuestoTotal,
    required this.totalGastos,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos el balance y el porcentaje de gasto
    final double balance = presupuestoTotal - totalGastos;
    // El porcentaje es cuánto has gastado de tu presupuesto. Evitamos división por cero.
    final double porcentajeGasto = presupuestoTotal > 0 ? totalGastos / presupuestoTotal : 0;
    
    // Convertimos a un valor entre 0 y 100 para el gráfico
    final double chartValue = (porcentajeGasto * 100).clamp(0, 100);

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
          Text('Total del mes', style: AppTextStyles.heading),
          const SizedBox(height: 24),
          _buildSummaryRow(icon: Icons.arrow_upward, color: Colors.green.shade700, label: 'Presupuesto', amount: presupuestoTotal.toStringAsFixed(0)),
          const SizedBox(height: 12),
          _buildSummaryRow(icon: Icons.arrow_downward, color: Colors.red.shade600, label: 'Gastos', amount: totalGastos.toStringAsFixed(0)),
          const Divider(height: 32),
          _buildSummaryRow(label: 'Balance', amount: balance.toStringAsFixed(0), isBalance: true),
          const SizedBox(height: 24),

          // --- 2. EL NUEVO GRÁFICO DE VELOCÍMETRO ---
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // El texto del centro
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${chartValue.toStringAsFixed(0)}%',
                      style: AppTextStyles.title.copyWith(color: AppColors.primary),
                    ),
                    Text(
                      'Gastado', // O "Ahorro" si prefieres
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
                // El gráfico de pastel que simula el velocímetro
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90, // Gira el gráfico para que empiece arriba
                    sectionsSpace: 4, // Espacio entre las secciones
                    centerSpaceRadius: 55, // El radio del agujero del centro
                    sections: [
                      // Sección de "Gastos"
                      PieChartSectionData(
                        value: chartValue,
                        color: AppColors.element, // Tu color verde/oliva
                        radius: 15,
                        showTitle: false,
                      ),
                      // Sección de "Lo que queda del presupuesto"
                      PieChartSectionData(
                        value: 100 - chartValue,
                        color: AppColors.element.withOpacity(0.2), // Mismo color, pero más claro
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
          // La leyenda del gráfico
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.element, 'Gastos'),
              const SizedBox(width: 24),
              _buildLegendItem(AppColors.element.withOpacity(0.2), 'Presupuesto'),
            ],
          )
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