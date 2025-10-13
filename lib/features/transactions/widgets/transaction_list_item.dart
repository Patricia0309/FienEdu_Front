import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

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
          child: Text(transaction.icon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(transaction.category, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.description, style: AppTextStyles.small),
            const SizedBox(height: 4),
            Text(DateFormat('d MMM').format(transaction.date), style: AppTextStyles.small.copyWith(color: Colors.grey.shade600)),
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