import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/transaction_service.dart';
import '../../inicial_setup/models/category_model.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_list_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  // --- 1. NUEVAS VARIABLES DE ESTADO ---
  bool _isLoading = true;
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<int, Category> _categoryMap = {};

  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = ['Todos', 'Ingresos', 'Gastos'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void refreshData() {
    print("TransactionsScreen: Refrescando datos...");
    // Ponemos isLoading a true brevemente para mostrar el spinner mientras recarga
    setState(() {
      _isLoading = true;
    });
    // Vuelve a llamar a la función que busca los datos de la API
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Obtenemos ambos sets de datos al mismo tiempo
      final results = await Future.wait([
        _transactionService.getTransactions(),
        _categoryService.getCategories(),
      ]);

      final transactions = results[0] as List<Transaction>;
      final categories = results[1] as List<Category>;

      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = transactions; // Al inicio, mostramos todo
        _categoryMap = {for (var cat in categories) cat.id: cat};
        _isLoading = false;
      });
    } catch (e) {
      // Manejar error
      setState(() {
        _isLoading = false;
      });
      print('Error al cargar datos: $e');
    }
  }

  // --- 2. LÓGICA PARA FILTRAR ---
  void _filterTransactions(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Ingresos':
          _filteredTransactions = _allTransactions
              .where((t) => t.type == TransactionType.ingreso)
              .toList();
          break;
        case 'Gastos':
          _filteredTransactions = _allTransactions
              .where((t) => t.type == TransactionType.gasto)
              .toList();
          break;
        default: // 'Todos'
          _filteredTransactions = _allTransactions;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSummaryCard(
            _allTransactions,
          ), // El resumen siempre muestra el total
          // --- 3. UI ACTUALIZADA ---
          // Si está cargando, muestra un spinner. Si no, la lista.
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      final category =
                          _categoryMap[transaction.categoryId] ??
                          Category(id: 0, title: 'Desconocida', icon: '❓');
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent2.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movimientos',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SvgPicture.asset('assets/img/svg/Logo.2.svg', height: 60),
            ],
          ),
          const SizedBox(height: 16),
          // El Dropdown ahora llama a la función de filtro
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
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
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _filterTransactions(newValue);
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
    // Calculamos los totales usando la lista completa (sin filtrar)
    double totalIngresos = transactions
        .where((t) => t.type == TransactionType.ingreso)
        .fold(0, (sum, t) => sum + t.amount);
    double totalGastos = transactions
        .where((t) => t.type == TransactionType.gasto)
        .fold(0, (sum, t) => sum + t.amount);

    return Card(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ), // Ajustamos margen superior
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4, // Añadimos un poco de elevación como en tu diseño
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
                // Mostramos el número total de transacciones
                Text(
                  transactions.length.toString(),
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Mostramos los totales calculados
                Text(
                  '⬆ \$${totalIngresos.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '⬇ \$${totalGastos.toStringAsFixed(0)}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
