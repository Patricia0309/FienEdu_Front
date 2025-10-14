// lib/features/transactions/screens/transactions_screen.dart

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
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
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
          Row(/* ... tu Row con el título y el logo no cambia ... */),
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
    // ... este widget no cambia ...
    return Card(/* ... */);
  }
}
