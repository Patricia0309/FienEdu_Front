// lib/features/transactions/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../inicial_setup/models/category_model.dart'; // Importamos el modelo de Categoría
import '../models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category
  category; // <-- 1. Ahora también recibe el objeto Category completo

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.ingreso;
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade600;
    final amountSign = isIncome ? '+' : '-';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          // 2. Usamos el ícono de la categoría
          child: Text(category.icon, style: const TextStyle(fontSize: 24)),
        ),
        // 3. Usamos el título de la categoría
        title: Text(
          category.title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La descripción puede que no venga de la API, la dejamos opcional
            if (transaction.description.isNotEmpty) ...[
              Text(transaction.description, style: AppTextStyles.small),
              const SizedBox(height: 4),
            ],
            Text(
              DateFormat('d MMM, yyyy').format(transaction.date),
              style: AppTextStyles.small.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Text(
          '$amountSign\$${transaction.amount.toStringAsFixed(0)}',
          style: AppTextStyles.heading.copyWith(color: amountColor),
        ),
      ),
    );
  }
}
