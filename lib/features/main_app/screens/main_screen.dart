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

  // 1. Añadimos la nueva pantalla a la lista
  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    TransactionsScreen(),
    AnalysisScreen(),
    Text('Pestaña Aprende'),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 2. Función para mostrar el modal de nueva transacción
  void _showNewTransactionModal(BuildContext context) async {
    // La hacemos 'async'
    // 'await' espera a que el modal se cierre y nos da su resultado
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewTransactionModal(),
    );

    // Si el resultado que nos devolvió el modal es 'true'...
    if (result == true) {
      // ...mostramos el SnackBar desde aquí, usando el context de MainScreen,
      // que es 100% válido y seguro.
      showSuccessSnackBar(context, 'Transacción guardada exitosamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      // 3. Añadimos el FloatingActionButton aquí para que sea visible en todas las pestañas
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTransactionModal(context),
        backgroundColor: const Color(0xFF4F772D),
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Posición

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
