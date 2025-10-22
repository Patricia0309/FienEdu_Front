import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/services/user_service.dart';
import '../../../features/profile/models/student_model.dart';
import '../../../features/transactions/models/transaction_model.dart';
import '../widgets/dashboard_actions_grid.dart';
import '../widgets/perfil_financiero_card.dart';
import '../widgets/total_mes_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/set_budget_modal.dart';
import '../../../data/services/budget_service.dart';
import '../../../features/budgets/models/budget_status_model.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();
  final BudgetService _budgetService = BudgetService();
  late Future<Map<String, dynamic>> _dashboardDataFuture;

  void _showSetBudgetModal(BudgetStatus? currentStatus) async {
     final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SetBudgetModal(
            // Pasa los datos del presupuesto actual si existe
            initialBudgetStatus: currentStatus,
        ),
     );
     // Si el modal devolvió true (se guardó), recarga los datos del dashboard
     if (saved == true) {
        setState(() {
          _dashboardDataFuture = _fetchDashboardData();
        });
     }
  }

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      // Usamos Future.wait para las llamadas obligatorias
      final results = await Future.wait([
        _userService.getMe(),
        _transactionService.getTransactions(),
      ]);

      // La llamada al status del presupuesto puede fallar (404), la hacemos por separado
      BudgetStatus? budgetStatus;
      try {
         budgetStatus = await _budgetService.getBudgetStatus();
      } catch (e) {
         print("No se encontró presupuesto activo o hubo un error: $e");
         // No hacemos nada, budgetStatus seguirá siendo null
      }

      return {
        'student': results[0] as Student,
        'transactions': results[1] as List<Transaction>,
        'budgetStatus': budgetStatus, // Puede ser null
      };
    } catch (e) {
       print("Error fatal cargando dashboard: $e");
       rethrow; // Re-lanza para que el FutureBuilder muestre el error
    }
  }

  // --- ESTA ES LA FUNCIÓN COMPLETA QUE FALTABA ---
  Map<String, dynamic> _processTransactionData(List<Transaction> transactions) {
    double totalIngresos = 0;
    double totalGastos = 0;

    Map<int, double> dailyExpenses = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var t in transactions) {
      if (t.type == TransactionType.ingreso) {
        totalIngresos += t.amount;
      } else {
        totalGastos += t.amount;
        if (t.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
          dailyExpenses[t.date.weekday - 1] =
              (dailyExpenses[t.date.weekday - 1] ?? 0) + t.amount;
        }
      }
    }

    final List<BarChartGroupData> chartData = [];
    dailyExpenses.forEach((day, total) {
      chartData.add(
        BarChartGroupData(
          x: day,
          barRods: [
            BarChartRodData(
              toY: total,
              color: AppColors.element,
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error al cargar el dashboard: ${snapshot.error}'),
            ),
          );
        }
        if (snapshot.hasData) {
          final student = snapshot.data!['student'] as Student;
          final transactions =
              snapshot.data!['transactions'] as List<Transaction>;
          final budgetStatus = snapshot.data!['budgetStatus'] as BudgetStatus?;

          print("DEBUG FLUTTER: Received BudgetStatus: budgetStatus?.totalSpent");

          final processedData = _processTransactionData(transactions);

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 120,
              backgroundColor: AppColors.accent2,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola,',
                    style: AppTextStyles.title.copyWith(color: Colors.white70),
                  ),
                  Text(
                    '${student.displayName ?? 'Usuario'} 👋', 
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                  ), // Padding a la derecha del logo
                  child: SvgPicture.asset(
                    'assets/img/svg/Logo.2.svg',
                    height: 80,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TotalMesCard(
                      budgetStatus: budgetStatus, // <-- Pasa el objeto completo (puede ser null)
                    ),
                    const SizedBox(height: 16),
                    BudgetCard(
                        budgetStatus: budgetStatus,
                        onSetBudgetTap: () => _showSetBudgetModal(budgetStatus),
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
        return const Scaffold(
          body: Center(child: Text('No se pudieron cargar los datos.')),
        );
      },
    );
  }
}
