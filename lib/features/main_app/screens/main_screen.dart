import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../transactions/widgets/new_transaction_modal.dart';

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
    Text('Pestaña Análisis'),
    Text('Pestaña Aprende'),
    Text('Pestaña Perfil'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // 2. Función para mostrar el modal de nueva transacción
  void _showNewTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 3. Añadimos el FloatingActionButton aquí para que sea visible en todas las pestañas
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTransactionModal(context),
        backgroundColor: const Color(0xFF4F772D),
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Posición
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Movimientos'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Análisis'),
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