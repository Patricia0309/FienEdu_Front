// lib/features/transactions/screens/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Asegúrate de tener este import
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/transaction_service.dart';
import '../../inicial_setup/models/category_model.dart'; // Cambiado a initial_setup
import '../models/transaction_model.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends StatefulWidget {
  // Añadimos el Key necesario para el GlobalKey
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  // Hacemos el State público
  TransactionsScreenState createState() => TransactionsScreenState();
}

// Hacemos el State público
class TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  // Variables de estado
  bool _isLoading = true;
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<int, Category> _categoryMap = {};

  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = ['Todos', 'Ingresos', 'Gastos'];

  @override
  void initState() {
    super.initState();
    _fetchData(); // Carga inicial de datos
  }

  // Método público para refrescar
  void refreshData() {
    print("TransactionsScreen: Refrescando datos...");
    // Muestra el spinner brevemente
    if (mounted) {
       setState(() { _isLoading = true; });
    }
    // Vuelve a llamar a la función que busca los datos
    _fetchData();
  }

  // Función para obtener los datos de la API
  Future<void> _fetchData() async {
    // Ponemos isLoading a true si no estamos ya cargando (evita doble spinner en refresh)
    if (mounted && !_isLoading) {
       setState(() { _isLoading = true; });
    }

    try {
      final results = await Future.wait([
        _transactionService.getTransactions(),
        _categoryService.getCategories(),
      ]);

      final transactions = results[0] as List<Transaction>;
      final categories = results[1] as List<Category>;

      // --- PRINT #1: ¿Cuántas transacciones llegaron de la API? ---
      print("TRANSACTIONS_SCREEN - _fetchData: Recibidas ${transactions.length} transacciones de la API.");
      // -----------------------------------------------------------

      if (mounted) {
        final categoryMap = {for (var cat in categories) cat.id: cat};
        // Aplicamos el filtro ANTES de setState para que la lista inicial sea correcta
        List<Transaction> initialFilteredList;
        switch (_selectedFilter) {
          case 'Ingresos': initialFilteredList = transactions.where((t) => t.type == TransactionType.ingreso).toList(); break;
          case 'Gastos': initialFilteredList = transactions.where((t) => t.type == TransactionType.gasto).toList(); break;
          default: initialFilteredList = transactions; break;
        }
        
        // --- PRINT #2: ¿Cuántas quedaron después del filtro inicial? ---
        print("TRANSACTIONS_SCREEN - _fetchData: Lista filtrada inicial tiene ${initialFilteredList.length} items.");
        // -------------------------------------------------------------

        setState(() {
          _allTransactions = transactions;
          _filteredTransactions = initialFilteredList; // Usamos la lista pre-filtrada
          _categoryMap = categoryMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        print('Error al cargar datos en TransactionsScreen: $e');
      }
    }
  }

  // Lógica para aplicar el filtro (separada para reutilizar)
  void _applyFilter(String filter, List<Transaction> sourceList) {
     switch (filter) {
        case 'Ingresos':
          _filteredTransactions = sourceList.where((t) => t.type == TransactionType.ingreso).toList();
          break;
        case 'Gastos':
          _filteredTransactions = sourceList.where((t) => t.type == TransactionType.gasto).toList();
          break;
        default: // 'Todos'
          _filteredTransactions = sourceList;
          break;
      }
  }

  // Lógica para cambiar el filtro y actualizar la UI
  void _filterTransactions(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter(filter, _allTransactions); // Aplicamos filtro a la lista completa
      
      // --- PRINT #3: ¿Cuántas quedaron después de cambiar el filtro? ---
      print("TRANSACTIONS_SCREEN - _filterTransactions: Lista filtrada AHORA tiene ${_filteredTransactions.length} items.");
      // ---------------------------------------------------------------
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Para ver el fondo de MainScreen
      body: Column(
        children: [
          _buildHeader(context),
          // Mostramos el resumen solo si no está cargando y hay transacciones
          if (!_isLoading && _allTransactions.isNotEmpty) 
             _buildSummaryCard(_allTransactions),
          
          // Muestra spinner o la lista
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  // Muestra mensaje si la lista filtrada está vacía
                  child: _filteredTransactions.isEmpty 
                      ? Center(child: Text('No hay transacciones para mostrar.', style: AppTextStyles.body))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            // --- PRINT #4: ¿Se está intentando construir la lista? ---
                            print("TRANSACTIONS_SCREEN - itemBuilder: Construyendo item $index");
                            // --------------------------------------------------------
                            final transaction = _filteredTransactions[index];
                            final category = _categoryMap[transaction.categoryId] ?? Category(id: 0, title: 'Desconocida', icon: '❓');
                            return TransactionListItem(
                              transaction: transaction,
                              category: category,
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  // --- Widgets Helper ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16, // Espacio para la barra de estado
        left: 16, right: 16, bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent2.withOpacity(0.8), // Color del header
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Movimientos', style: AppTextStyles.title.copyWith(color: AppColors.primary)),
              SvgPicture.asset(
                  'assets/img/svg/Logo.1.svg', // Asegúrate que la ruta sea correcta
                  height: 40,
                  colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            ],
          ),
          const SizedBox(height: 16),
          // Dropdown de filtro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedFilter,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _filterOptions.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _filterTransactions(newValue); // Llama a la función de filtro
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Transaction> transactions) {
    double totalIngresos = transactions.where((t) => t.type == TransactionType.ingreso).fold(0, (sum, t) => sum + t.amount);
    double totalGastos = transactions.where((t) => t.type == TransactionType.gasto).fold(0, (sum, t) => sum + t.amount);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total transacciones', style: AppTextStyles.body),
                Text(transactions.length.toString(), style: AppTextStyles.subtitle),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('⬆ \$${totalIngresos.toStringAsFixed(0)}', style: AppTextStyles.body.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                Text('⬇ \$${totalGastos.toStringAsFixed(0)}', style: AppTextStyles.body.copyWith(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
} 