// lib/features/main_app/screens/main_screen.dart

import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../transactions/widgets/new_transaction_modal.dart';
import '../../analysis/screens/analysis_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../common/utils/show_snackbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- 1. Claves Globales para acceder a los States ---
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<TransactionsScreenState> _transactionsKey =
      GlobalKey<TransactionsScreenState>();
  // Añade más claves si otras pestañas necesitan refresco (ej. AnalysisScreen)

  // Lista de widgets con sus claves asignadas
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // --- 2. Asigna las claves al crear los widgets ---
    _widgetOptions = <Widget>[
      // Asegúrate que DashboardScreen sea StatefulWidget
      DashboardScreen(key: _dashboardKey),
      // Asegúrate que TransactionsScreen sea StatefulWidget
      TransactionsScreen(key: _transactionsKey),
      const AnalysisScreen(), // Podría necesitar key y refresh si muestra datos dinámicos
      const Text('Pestaña Aprende'), // Placeholder
      const ProfileScreen(), // Ya usa FutureBuilder para refrescarse
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función para mostrar el modal (ahora llama a refresco)
  void _showNewTransactionModal(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewTransactionModal(),
    );

    if (result == true) {
      // Si se guardó exitosamente
      if (mounted) {
        showSuccessSnackBar(context, 'Transacción guardada exitosamente');
        _refreshCurrentTabData();
        print(">>> LLAMANDO A REFRESCAR DATOS <<<");
        
      }
    }
  }

  // --- 4. Función que refresca la pestaña activa ---
  void _refreshCurrentTabData() {
    print("MainScreen: Transaction saved, refreshing relevant screens...");
    // Llama a refreshData en el Dashboard SIEMPRE
    _dashboardKey.currentState?.refreshData();
    // Llama a refreshData en Movimientos SIEMPRE
    _transactionsKey.currentState?.refreshData();
    
    // No necesitas el switch(_selectedIndex) aquí
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo correcto
      body: Stack(
        // Mantenemos el stack para el fondo opaco
        children: [
          Container(color: Colors.black.withOpacity(0.05)),
          // Usamos IndexedStack para mantener el estado de las pestañas inactivas
          IndexedStack(index: _selectedIndex, children: _widgetOptions),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTransactionModal(context),
        backgroundColor: const Color(0xFF4F772D),
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
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
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Aprende'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
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
  }
}
