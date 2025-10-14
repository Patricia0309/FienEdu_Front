import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class TotalMesCard extends StatelessWidget {
  final double totalIngresos;
  final double totalGastos;
  final List<BarChartGroupData> chartData;

  const TotalMesCard({
    super.key,
    required this.totalIngresos,
    required this.totalGastos,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final double balance = totalIngresos - totalGastos;

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
          Text('Total del mes', style: AppTextStyles.heading),
          const SizedBox(height: 24),
          _buildSummaryRow(
            icon: Icons.arrow_upward,
            color: Colors.green.shade700,
            label: 'Ingresos',
            amount: totalIngresos.toStringAsFixed(0),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            icon: Icons.arrow_downward,
            color: Colors.red.shade600,
            label: 'Gastos',
            amount: totalGastos.toStringAsFixed(0),
          ),
          const Divider(height: 32),
          _buildSummaryRow(
            label: 'Balance',
            amount: balance.toStringAsFixed(0),
            isBalance: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: chartData,
              ),
            ),
          ),
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
}
