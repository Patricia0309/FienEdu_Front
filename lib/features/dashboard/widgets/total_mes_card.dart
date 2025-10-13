// lib/features/dashboard/widgets/total_mes_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class TotalMesCard extends StatelessWidget {
  const TotalMesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total del mes', style: AppTextStyles.heading),
            const SizedBox(height: 24),
            _buildSummaryRow(
              icon: Icons.arrow_upward,
              color: AppColors.accent1,
              label: 'Ingresos',
              amount: '15,000',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.arrow_downward,
              color: const Color(0xFFF43F5E),
              label: 'Gastos',
              amount: '8,500',
            ),
            const Divider(height: 32),
            _buildSummaryRow(
              label: 'Balance',
              amount: '6,500',
              isBalance: true,
            ),
            const SizedBox(height: 24),
            // La Gráfica de Barras
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: _getBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget interno para no repetir código en las filas
  Widget _buildSummaryRow({IconData? icon, Color? color, required String label, required String amount, bool isBalance = false}) {
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
            Text(label, style: isBalance ? AppTextStyles.body.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.body),
          ],
        ),
        Text('\$$amount', style: amountStyle),
      ],
    );
  }

  // Datos duros para la gráfica
  List<BarChartGroupData> _getBarGroups() {
    return [
      _makeGroupData(0, 5, AppColors.accent1), // Ingreso
      _makeGroupData(1, 8, const Color(0xFFF43F5E)), // Gasto
      _makeGroupData(2, 4, const Color(0xFFF59E0B)), // Balance
      _makeGroupData(3, 7, AppColors.accent1), // Ingreso
      _makeGroupData(4, 6, const Color(0xFFF43F5E)), // Gasto
      _makeGroupData(5, 5.5, const Color(0xFFF59E0B)), // Balance
      _makeGroupData(6, 4, AppColors.accent1), // Ingreso
    ];
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}