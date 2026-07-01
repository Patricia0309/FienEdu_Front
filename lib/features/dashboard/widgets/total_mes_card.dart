// lib/features/dashboard/widgets/total_mes_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math'; // Para min y max
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class TotalMesCard extends StatelessWidget {
  final double presupuestoTotal;
  final double totalGastos;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int daysLeft;

  const TotalMesCard({
    super.key,
    required this.presupuestoTotal,
    required this.totalGastos,
    this.fechaInicio,
    this.fechaFin,
    required this.daysLeft,
  });

  String formatearFecha(DateTime fecha) {
    return DateFormat('d MMM', 'es_MX').format(fecha);
  }

  // --- LÓGICA DE COLORES UNIFICADA ---
  Color _getDynamicColor(double percentage) {
    if (percentage >= 0.95)
      return Colors.red.shade700; // 100% o más: Crítico (Gasto excedido)
    if (percentage >= 0.70)
      return Colors.orangeAccent; // 70% - 99%: Advertencia
    if (percentage >= 0.40) return Colors.amber; // 40% - 69%: Moderado
    return AppColors.element; // Menos de 40%: Saludable (Verde/Azul base)
  }

  @override
  Widget build(BuildContext context) {
    final double gastos = totalGastos;
    final double presupuesto = presupuestoTotal;

    final double gastosDentroDelPresupuesto = min(gastos, presupuesto);
    final double gastoExtra = max(0, gastos - presupuesto);
    final double restante = max(0, presupuesto - gastos);

    // Calculamos el porcentaje real (puede ser mayor a 1.0 si hay gasto extra)
    final double porcentajeGasto = presupuesto > 0
        ? (gastos / presupuesto)
        : 0.0;

    // El valor para la dona se limita a un máximo de 100 por el PieChart
    final double chartValue = (porcentajeGasto * 100).clamp(0.0, 100.0);

    // Obtenemos el color dinámico basado en la situación real del mes
    final Color estadoColor = _getDynamicColor(porcentajeGasto);

    final bool showChart = presupuesto > 0;

    print(
      "DEBUG WIDGET: TotalMesCard CONSTRUIDO con gastos: $gastos, presupuesto: $presupuesto, extra: $gastoExtra, %: $porcentajeGasto",
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
          if (presupuestoTotal > 0 &&
              fechaInicio != null &&
              fechaFin != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  '${formatearFecha(fechaInicio!)} - ${formatearFecha(fechaFin!)}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
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
                        '${(porcentajeGasto * 100).toStringAsFixed(0)}%', // Muestra el porcentaje real (ej: 115%)
                        style: AppTextStyles.title.copyWith(
                          color:
                              estadoColor, // <-- Modificado: El texto central cambia de color
                          fontWeight: FontWeight.bold,
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
                        // Sección de lo Gastado
                        PieChartSectionData(
                          value: chartValue,
                          color:
                              estadoColor, // <-- Modificado: Color dinámico para la dona
                          radius: 15,
                          showTitle: false,
                        ),
                        // Sección de lo Restante
                        PieChartSectionData(
                          value: (100 - chartValue).clamp(0, 100),
                          color: estadoColor.withOpacity(
                            0.15,
                          ), // <-- Modificado: Fondo sutil a juego con el estado
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
                _buildLegendItem(
                  estadoColor,
                  'Gastado',
                ), // <-- Modificado: Leyenda dinámica
                const SizedBox(width: 24),
                _buildLegendItem(
                  estadoColor.withOpacity(
                    0.2,
                  ), // <-- Modificado: Leyenda dinámica
                  'Restante',
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Ups! No tienes un presupuesto activo para hoy.',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
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
