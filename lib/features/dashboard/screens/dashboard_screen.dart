// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/transaction_service.dart';
import '../../../features/transactions/models/transaction_model.dart';
import '../widgets/dashboard_actions_grid.dart';
import '../widgets/perfil_financiero_card.dart';
import '../widgets/total_mes_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionService.getTransactions();
  }

  // --- FUNCIÓN CLAVE PARA PROCESAR LOS DATOS ---
  Map<String, dynamic> _processTransactionData(List<Transaction> transactions) {
    double totalIngresos = 0;
    double totalGastos = 0;

    // Mapa para agrupar gastos por día de la semana (0=Lunes, 6=Domingo)
    Map<int, double> dailyExpenses = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var t in transactions) {
      if (t.type == TransactionType.ingreso) {
        totalIngresos += t.amount;
      } else {
        totalGastos += t.amount;
        // Agrupamos el gasto en el día de la semana correspondiente
        dailyExpenses[t.date.weekday - 1] =
            dailyExpenses[t.date.weekday - 1]! + t.amount;
      }
    }

    // Convertimos los datos agrupados al formato que espera la gráfica
    final List<BarChartGroupData> chartData = [];
    dailyExpenses.forEach((day, total) {
      chartData.add(
        BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(
              toY: total,
              color: AppColors.primary, // Usamos un color base
              width: 15,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    });

    return {
      'totalIngresos': totalIngresos,
      'totalGastos': totalGastos,
      'chartData': chartData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(/* ... tu AppBar no cambia ... */),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar el dashboard: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            final transactions = snapshot.data!;
            // Procesamos los datos justo antes de construir la UI
            final processedData = _processTransactionData(transactions);

            return SingleChildScrollView(
              child: Container(
                color: AppColors.background,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TotalMesCard(
                        totalIngresos: processedData['totalIngresos'],
                        totalGastos: processedData['totalGastos'],
                        chartData: processedData['chartData'],
                      ),
                      const SizedBox(height: 16),
                      const PerfilFinancieroCard(),
                      const SizedBox(height: 16),
                      const DashboardActionsGrid(),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: Text('Añade tu primera transacción para empezar.'),
          );
        },
      ),
    );
  }
}
