// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fl_chart/fl_chart.dart'; // No usamos la gráfica de barras aquí
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
import '../../../data/services/analytics_service.dart';
import '../../../features/analysis/models/profile_response_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();
  final BudgetService _budgetService = BudgetService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // State Variables
  Student? _studentData;
  List<Transaction> _transactionsData = [];
  BudgetStatus? _budgetStatusData;
  BudgetStatus? get currentBudgetStatus => _budgetStatusData;
  ProfileResponse? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // --- FUNCIÓN DE CARGA/RECARGA ---
  Future<void> _fetchDashboardData({bool isRefreshing = false}) async {
    if (isRefreshing || _studentData == null) {
      if (mounted)
        setState(() {
          _isLoading = true;
          _error = null;
        });
    }

    try {
      // Hacemos las 3 llamadas en paralelo
      final results = await Future.wait([
        _userService.getMe(),
        _transactionService.getTransactions(),
        _budgetService.getBudgetStatus(),

        _analyticsService.getProfile().catchError((e) {
          print("Error cargando perfil en Dashboard: $e");
          return null; // Devuelve null si falla
        }),
        // Esta puede devolver null
      ]);

      if (mounted) {
        setState(() {
          _studentData = results[0] as Student;
          _transactionsData = results[1] as List<Transaction>;
          _budgetStatusData = results[2] as BudgetStatus?;
          _profileData = results[3] as ProfileResponse?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains(
          'No tienes un período de presupuesto activo',
        )) {
          _fetchDataSafely();
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
        _analyticsService.getProfile().catchError((e) {
          print("Error cargando perfil en Dashboard (Safe): $e");
          return null;
        }),
      ]);
      if (mounted) {
        setState(() {
          _studentData = results[0] as Student;
          _transactionsData = results[1] as List<Transaction>;
          _profileData = results[2] as ProfileResponse?;
          _budgetStatusData = null; // Sabemos que falló
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // --- MÉTODO DE REFRESCO PÚBLICO ---
  Future<void> refreshData() async {
    print("DashboardScreen: Refreshing data via refreshData()...");
    await _fetchDashboardData(isRefreshing: true);
  }

  // --- MOSTRAR MODAL DE PRESUPUESTO ---
  void _showSetBudgetModal(BudgetStatus? currentStatus) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetBudgetModal(initialBudgetStatus: currentStatus),
    );
    if (saved == true) {
      refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildContent(),
    );
  }

  // --- HELPER PARA CONSTRUIR EL CONTENIDO ---
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error al cargar el dashboard: $_error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: refreshData,
              ),
            ],
          ),
        ),
      );
    }

    if (_studentData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudieron cargar los datos del usuario.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // --- ESTADO DE ÉXITO ---
    final student = _studentData!;
    final transactions = _transactionsData ?? [];
    final budgetStatus = _budgetStatusData;
    final profile = _profileData;

    // --- LÓGICA DE CÁLCULO EN FLUTTER (CORREGIDA) ---
    double presupuestoCalculado = 0.0;
    double gastosCalculados = 0.0;

    if (budgetStatus != null) {
      presupuestoCalculado = budgetStatus.totalIncome;

      // Usamos las fechas del presupuesto tal como vienen (asumimos que son UTC)
      final DateTime budgetStart = budgetStatus.startDate;
      final DateTime budgetEnd = budgetStatus.endDate;

      print("DEBUG DASHBOARD: Rango de presupuesto: $budgetStart a $budgetEnd");

      // Calculamos los gastos NOSOTROS MISMOS, usando la lista de transacciones
      gastosCalculados = transactions
          .where((t) {
            // t.date ya es un DateTime (probablemente en UTC de la API)

            // Imprimimos la comparación para depurar
            print(
              "DEBUG DASHBOARD: Checando Tx ID ${t.id} (Fecha: ${t.date})... Es gasto? ${t.type == TransactionType.gasto}. Es después de inicio? ${!t.date.isBefore(budgetStart)}. Es antes de fin? ${!t.date.isAfter(budgetEnd)}",
            );

            return t.type == TransactionType.gasto &&
                !t.date.isBefore(budgetStart) && // t.date >= budgetStart
                !t.date.isAfter(budgetEnd); // t.date <= budgetEnd
          })
          .fold(0.0, (sum, t) => sum + t.amount);

      print(
        "DEBUG DASHBOARD: Calculando gastos... Presupuesto: $presupuestoCalculado, Gasto (calculado en Flutter): $gastosCalculados",
      );
    } else {
      print("DEBUG DASHBOARD: No hay presupuesto activo.");
    }
    // --- FIN DE LA LÓGICA ---

    // Construimos la UI final
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
                PerfilFinancieroCard(
                  profileName:
                      profile?.profile ?? 'Calculando...', // Pasa el nombre
                  description: '',
                ),
                const SizedBox(height: 16),
                const DashboardActionsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FUNCIÓN HELPER PARA EL APPBAR ---
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
          padding: const EdgeInsets.only(right: 24.0),
          child: SvgPicture.asset(
            'assets/img/svg/Logo.1.svg', // Asegúrate que la ruta sea correcta
            height: 40,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
      titleSpacing: 0,
    );
  }
}
