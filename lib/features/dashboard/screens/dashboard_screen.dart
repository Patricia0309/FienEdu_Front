// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/budget_service.dart';
import '../../../features/profile/models/student_model.dart';
import '../../../features/transactions/models/transaction_model.dart';
import '../../../features/budgets/models/budget_status_model.dart';
import '../widgets/dashboard_actions_grid.dart';
import '../widgets/perfil_financiero_card.dart';
import '../widgets/total_mes_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/set_budget_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();
  final BudgetService _budgetService = BudgetService();

  // State Variables
  Student? _studentData;
  List<Transaction>? _transactionsData;
  BudgetStatus? _budgetStatusData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // --- FUNCIÓN DE CARGA/RECARGA ---
  Future<void> _fetchDashboardData({bool isRefreshing = false}) async {
    // Muestra spinner solo en carga inicial O si se indica refresco explícito
    if (isRefreshing || _studentData == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      }); // Limpia error si solo se actualiza estado
    }

    try {
      // Pedimos todos los datos necesarios
      final results = await Future.wait([
        _userService.getMe(),
        _transactionService.getTransactions(),
      ]);
      BudgetStatus? budgetStatus;
      try {
        budgetStatus = await _budgetService.getBudgetStatus();
      } catch (e) {
        print("Dashboard: No se encontró presupuesto activo o hubo error: $e");
        budgetStatus = null;
      }

      // IMPORTANTE: Verificar si el widget sigue montado ANTES de llamar a setState
      if (mounted) {
        setState(() {
          _studentData = results[0] as Student;
          _transactionsData = results[1] as List<Transaction>;
          _budgetStatusData = budgetStatus;
          _isLoading = false; // <<< --- MARCA COMO CARGA COMPLETADA AQUÍ
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false; // <<< --- MARCA COMO CARGA COMPLETADA (CON ERROR)
        });
      }
    }
  }

  // --- MÉTODO DE REFRESCO PÚBLICO ---
  // Ahora es async para poder esperar a que _fetch termine si quisiéramos
  Future<void> refreshData() async {
    print("DashboardScreen: Refreshing data via refreshData()...");
    // Just call the fetch function. It handles its own setState.
    await _fetchDashboardData(isRefreshing: true);
  }

  void _showSetBudgetModal(BudgetStatus? currentStatus) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetBudgetModal(initialBudgetStatus: currentStatus),
    );
    // If saved, refresh the dashboard data
    if (saved == true) {
      refreshData();
    }
  }

  // Función para procesar datos (sin cambios)
  // Process Transaction Data function (remains the same)
  Map<String, dynamic> _processTransactionData(List<Transaction> transactions) {
    double totalIngresos = 0;
    double totalGastos = 0;
    Map<int, double> dailyExpenses = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var t in transactions) {
      if (t.type == TransactionType.ingreso) {
        totalIngresos += t.amount;
      } else {
        totalGastos += t.amount;
        // Consider only recent expenses for the simple bar chart
        if (t.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
          dailyExpenses[t.date.weekday - 1] =
              (dailyExpenses[t.date.weekday - 1] ?? 0) + t.amount;
        }
      }
    }

    final List<BarChartGroupData> chartData = [];
    dailyExpenses.forEach((day, total) {
      // Create BarChartGroupData only if total > 0 to avoid empty bars
      if (total > 0) {
        chartData.add(
          BarChartGroupData(
            x: day,
            barRods: [
              BarChartRodData(
                toY: total,
                color: AppColors.primary,
                width: 15,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    });

    // Ensure chartData has entries for all days if needed, or handle empty state in chart widget
    // For now, it will only contain days with expenses.

    return {
      'totalIngresos': totalIngresos,
      'totalGastos': totalGastos,
      'chartData': chartData, // This is potentially sparse
    };
  }

  @override
  Widget build(BuildContext context) {
    // Construye la UI basada en el estado actual
    return Scaffold(body: _buildContent());
  }

  // Helper para construir el contenido
  Widget _buildContent() {
    // Muestra spinner solo en la carga inicial
    if (_isLoading && _studentData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Muestra error si existe
    if (_error != null) {
      return Center(child: Column(/* ... Error UI ... */));
    }
    // Si tenemos datos, construye la pantalla
    if (_studentData != null && _transactionsData != null) {
      final student = _studentData!;
      final transactions = _transactionsData!;
      // Procesamos datos aquí, asegurando que son los más recientes
      final processedData = _processTransactionData(transactions);

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: AppColors.element, // Use correct color
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          title: Padding(
            // Added padding
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola,',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                Text(
                  '${student.displayName ?? 'Usuario'} 👋',
                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              // Added logo
              padding: const EdgeInsets.only(right: 24.0),
              child: SvgPicture.asset(
                'assets/img/svg/Logo.1.svg', // Ensure path is correct
                height: 40,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
          titleSpacing: 0,
        ),
        body: RefreshIndicator(
          // <-- Opcional: Añade "pull-to-refresh"
          onRefresh:
              refreshData, // Llama a nuestro método al deslizar hacia abajo
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Asegura que siempre se pueda hacer pull-to-refresh
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TotalMesCard(
                    budgetStatus: _budgetStatusData,
                  ), // Usa el estado actual
                  const SizedBox(height: 16),
                  BudgetCard(
                    budgetStatus: _budgetStatusData, // Usa el estado actual
                    onSetBudgetTap: () =>
                        _showSetBudgetModal(_budgetStatusData),
                  ),
                  const SizedBox(height: 16),
                  const PerfilFinancieroCard(),
                  const SizedBox(height: 16),
                  const DashboardActionsGrid(),
                ],
              ),
            ),
          ),
        ),
      );
    }
    // Fallback
    return const Center(child: Text('Cargando datos...'));
  }
}
