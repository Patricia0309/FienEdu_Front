import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends StatelessWidget {
  // 1. La solución es simplemente quitar 'const' del constructor
  TransactionsScreen({super.key});

  // 2. Corregimos los datos de ejemplo para usar DateTime real
  final List<Transaction> _transactions = [
    Transaction(category: 'Salario', icon: '💰', description: 'Pago mensual', amount: 15000, date: DateTime(2025, 9, 30), type: TransactionType.ingreso),
    Transaction(category: 'Alimentación', icon: '🍔', description: 'Supermercado', amount: 450, date: DateTime(2025, 10, 1), type: TransactionType.gasto),
    Transaction(category: 'Transporte', icon: '🚗', description: 'Uber', amount: 200, date: DateTime(2025, 10, 2), type: TransactionType.gasto),
    Transaction(category: 'Entretenimiento', icon: '🎮', description: 'Cine y cena', amount: 800, date: DateTime(2025, 10, 3), type: TransactionType.gasto),
    Transaction(category: 'Freelance', icon: '💻', description: 'Proyecto web', amount: 3000, date: DateTime(2025, 10, 4), type: TransactionType.ingreso),
    Transaction(category: 'Suscripciones', icon: '💳', description: 'Netflix', amount: 299, date: DateTime(2025, 10, 5), type: TransactionType.gasto),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSummaryCard(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return TransactionListItem(transaction: _transactions[index]);
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
          Text('Transacciones', style: AppTextStyles.title.copyWith(color: AppColors.primary)),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          Row(
            children: [
              // Placeholder para el filtro
              Expanded(child: TextButton.icon(icon: Icon(Icons.filter_list), label: Text('Todos'), onPressed: (){})),
              IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined)),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total transacciones', style: AppTextStyles.body),
                Text(_transactions.length.toString(), style: AppTextStyles.subtitle),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('⬆ \$18,000', style: AppTextStyles.body.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                Text('⬇ \$2,249', style: AppTextStyles.body.copyWith(color: Colors.red.shade600, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}