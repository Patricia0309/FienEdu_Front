// lib/features/main_app/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/theme/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../transactions/widgets/new_transaction_modal.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../common/utils/show_snackbar.dart';
import '../../../data/services/notification_service.dart';
import '../../budgets/models/budget_status_model.dart';
import '../../learn/screens/learn_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<TransactionsScreenState> _transactionsKey =
      GlobalKey<TransactionsScreenState>();

  // Llaves para el tutorial
  final GlobalKey _keyPresupuesto = GlobalKey();
  final GlobalKey _keyTransaccion = GlobalKey();

  late final List<Widget> _widgetOptions;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      DashboardScreen(
        key: _dashboardKey,
        budgetKey: _keyPresupuesto,
      ), // Esta usará la _keyPresupuesto por dentro
      TransactionsScreen(key: _transactionsKey),
      const AnalysisScreen(),
      const LearnScreen(),
      const ProfileScreen(),
    ];
    _notificationService.initialize();

    // NOTA: Quitamos el addPostFrameCallback de aquí porque ahora vive en el build
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNewTransactionModal(BuildContext context) async {
    final dashboardState = _dashboardKey.currentState;
    final BudgetStatus? budgetStatus = dashboardState?.currentBudgetStatus;

    if (budgetStatus == null || !budgetStatus.isActive) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Debes tener un presupuesto activo para añadir transacciones.',
        );
      }
      return;
    }

    final int activePeriodId = budgetStatus.incomePeriodId;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewTransactionModal(incomePeriodId: activePeriodId),
    );

    if (result == true) {
      if (mounted) {
        showSuccessSnackBar(context, 'Transacción guardada exitosamente');
        _refreshCurrentTabData();
      }
    }
  }

  void _refreshCurrentTabData() {
    _dashboardKey.currentState?.refreshData();
    _transactionsKey.currentState?.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    // --- SOLUCIÓN AL ERROR DE BUILDER ---
    return ShowCaseWidget(
      onFinish: () => print("Tutorial terminado"),
      // Aquí el cambio: Pasamos la función (context) => ... directamente
      builder: (context) {
        // Disparamos el tutorial cuando este contexto esté listo
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 1. Revisamos si ya vio el tutorial antes (Memoria local)
          final prefs = await SharedPreferences.getInstance();
          bool yaVioTutorial = prefs.getBool('tutorial_visto') ?? false;

          // 2. Revisamos si tiene presupuesto activo (Usando tu lógica actual)
          final dashboardState = _dashboardKey.currentState;
          bool tienePresupuesto =
              dashboardState?.currentBudgetStatus?.isActive ?? false;

          // 3. SOLO SI es nuevo Y NO tiene presupuesto, lanzamos el tutorial
          if (!yaVioTutorial && !tienePresupuesto) {
            if (mounted) {
              ShowCaseWidget.of(
                context,
              ).startShowCase([_keyPresupuesto, _keyTransaccion]);

              // 4. Marcamos como "visto" para que no vuelva a salir nunca más
              await prefs.setBool('tutorial_visto', true);
            }
          }
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Container(color: Colors.black.withOpacity(0.05)),
              IndexedStack(index: _selectedIndex, children: _widgetOptions),
            ],
          ),

          floatingActionButton: Showcase(
            key: _keyTransaccion,
            title: 'Registra tus gastos',
            description:
                'Cuando ya tengas un presupuesto, usa este botón para añadir tus movimientos.',
            child: FloatingActionButton(
              onPressed: () => _showNewTransactionModal(context),
              backgroundColor: const Color(0xFF4F772D),
              child: const Icon(Icons.add, color: Colors.white),
              shape: const CircleBorder(),
            ),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Movimientos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Análisis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Aprende',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,
            showUnselectedLabels: true,
          ),
        );
      },
    );
  }
}
