// lib/features/transactions/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../inicial_setup/models/category_model.dart';
import '../models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final Function(int) onEdit; // <-- Cambiado para pasar el ID de la transacción
  final VoidCallback onDelete; // <-- Para manejar la eliminación

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.category,
    required this.onEdit, // <-- Obligatorio
    required this.onDelete, // <-- Obligatorio
  });

  @override
  Widget build(BuildContext context) {
    print(
      "DEBUG TransactionListItem: Recibida transaction.description = '${transaction.description}' para ID ${transaction.id}",
    );
    final bool isIncome = transaction.type == TransactionType.ingreso;
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade600;
    final amountSign = isIncome ? '+' : '-';

    final String displayTitle;
    final String displayIcon;
    final String displaySubtitle;

    if (isIncome) {
      displayTitle = transaction.description.isNotEmpty
          ? transaction.description
          : 'Ingreso';
      displayIcon = '💵';
      displaySubtitle = '';
    } else {
      displayTitle = category.title;
      displayIcon = category.icon;
      displaySubtitle = transaction.description;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Text(displayIcon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          displayTitle,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displaySubtitle.isNotEmpty && !isIncome) ...[
              Text(
                displaySubtitle,
                style: AppTextStyles.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              DateFormat('d MMM, yyyy').format(transaction.date),
              style: AppTextStyles.small.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        // --- SECCIÓN MODIFICADA: Empaquetamos monto y botones en un Row compacto ---
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amountSign\$${transaction.amount.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 20),
            // Botón Lápiz (Editar)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color.fromARGB(255, 33, 91, 35),
                size: 30,
              ),
              onPressed: () => onEdit(
                transaction.id,
              ), // <-- Envía el ID directo al invocarlo
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ],
        ),
      ),
    );
  }
}
