// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Student? _studentData;
  List<Transaction> _transactionsData = []; // Inicializa como lista vacía
  BudgetStatus? _budgetStatusData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData({bool isRefreshing = false}) async {
    if (isRefreshing || _studentData == null) {
       setState(() { _isLoading = true; _error = null; });
    }

    try {
      // Hacemos las 3 llamadas en paralelo
      final results = await Future.wait([
        _userService.getMe(),
        _transactionService.getTransactions(),
        _budgetService.getBudgetStatus(), // Esta puede devolver null
      ]);

      if (mounted) {
        setState(() {
          _studentData = results[0] as Student;
          _transactionsData = results[1] as List<Transaction>;
          _budgetStatusData = results[2] as BudgetStatus?;
          _isLoading = false;
        });
      }
    } catch (e) {
       if (mounted) {
         // Manejo de error si budgetStatus falla (404)
         if (e.toString().contains('No tienes un período de presupuesto activo')) {
           _fetchDataSafely(); // Llama al modo seguro
         } else {
           setState(() {
            _error = e.toString().replaceFirst('Exception: ', '');
            _isLoading = false;
           });
         }
       }
    }
  }

  // Modo seguro si getBudgetStatus falla con 404
  Future<void> _fetchDataSafely() async {
     print("Ejecutando _fetchDataSafely (porque budget falló)");
     try {
       final results = await Future.wait([
          _userService.getMe(),
          _transactionService.getTransactions(),
        ]);
       if(mounted) {
          setState(() {
            _studentData = results[0] as Student;
            _transactionsData = results[1] as List<Transaction>;
            _budgetStatusData = null; // Sabemos que falló
            _isLoading = false;
          });
       }
     } catch(e) {
         if (mounted) {
           setState(() {
            _error = e.toString().replaceFirst('Exception: ', '');
            _isLoading = false;
           });
         }
     }
  }

  Future<void> refreshData() async {
    print("DashboardScreen: Refreshing data via refreshData()...");
    await _fetchDashboardData(isRefreshing: true);
  }

  void _showSetBudgetModal(BudgetStatus? currentStatus) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetBudgetModal(initialBudgetStatus: currentStatus),
    );
    if (saved == true) refreshData();
  }

  // Esta función ya no es necesaria aquí
  // Map<String, dynamic> _processChartData(List<Transaction> transactions) { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Error al cargar el dashboard: $_error'),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: refreshData, child: const Text('Reintentar')),
        ],
      ));
    }

    if (_studentData == null) {
       return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('No se pudieron cargar los datos del usuario.'),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: refreshData, child: const Text('Reintentar')),
        ],
      ));
    }

    final student = _studentData!;
    final transactions = _transactionsData ?? []; // Usa lista vacía si es null
    final budgetStatus = _budgetStatusData; // Puede ser null

    // --- LÓGICA DE CÁLCULO EN FLUTTER ---
    double presupuestoCalculado = 0.0;
    double gastosCalculados = 0.0;

    if (budgetStatus != null) {
      // 1. El presupuesto SÍ viene del budgetStatus
      presupuestoCalculado = budgetStatus.totalIncome;

      // 2. Calculamos los gastos NOSOTROS MISMOS, usando la lista de transacciones
      gastosCalculados = transactions
          .where((t) => 
              t.type == TransactionType.gasto &&
              !t.date.isBefore(budgetStatus.startDate) && // date >= start
              !t.date.isAfter(budgetStatus.endDate.add(const Duration(days: 1)))) // date <= end (añadimos 1 día para incluir el día final)
          .fold(0.0, (sum, t) => sum + t.amount);

       print("DEBUG DASHBOARD: Calculando gastos... Presupuesto: $presupuestoCalculado, Gasto (calculado en Flutter): $gastosCalculados");

    } else {
       print("DEBUG DASHBOARD: No hay presupuesto activo.");
    }
    // --- FIN DE LA LÓGICA ---


    return Scaffold(
      appBar: _buildAppBar(student), // Llama a la función helper
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 3. Pasamos los valores calculados en Flutter
                TotalMesCard(
                  presupuestoTotal: presupuestoCalculado,
                  totalGastos: gastosCalculados,
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
      ),
    );
  }

  // Función helper para el AppBar (la teníamos definida antes)
  AppBar _buildAppBar(Student student) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: AppColors.element,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hola,', style: AppTextStyles.body.copyWith(color: Colors.white70)),
            Text('${student.displayName ?? 'Usuario'} 👋', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
          ],
        ),
      ),
      actions: [
         Padding(
           padding: const EdgeInsets.only(right: 24.0),
           child: SvgPicture.asset('assets/img/svg/Logo.1.svg', height: 40, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
         ),
      ],
      titleSpacing: 0,
    );
  }
}