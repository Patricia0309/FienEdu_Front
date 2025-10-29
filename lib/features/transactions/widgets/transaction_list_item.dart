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
    print(
      "DEBUG TransactionListItem: Recibida transaction.description = '${transaction.description}' para ID ${transaction.id}",
    );
    final bool isIncome = transaction.type == TransactionType.ingreso;
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade600;
    final amountSign = isIncome ? '+' : '-';

    final String displayTitle;
    final String displayIcon;
    final String displaySubtitle; // Variable extra para el subtítulo

    if (isIncome) {
      // Si es Ingreso, el título es la Descripción, el ícono es 💵, y no hay subtítulo extra.
      // Usamos 'Ingreso' como fallback si la descripción está vacía.
      displayTitle = transaction.description.isNotEmpty
          ? transaction.description
          : 'Ingreso';
      displayIcon = '💵';
      displaySubtitle = ''; // Los ingresos no tienen categoría como subtítulo
    } else {
      // Si es Gasto, el título es la Categoría, el ícono es el de la categoría.
      displayTitle = category.title;
      displayIcon = category.icon;
      // El subtítulo puede ser la descripción de la transacción (si existe)
      displaySubtitle = transaction.description;
    }
    // --- FIN LÓGICA MODIFICADA ---

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          // 2. Usamos el ícono de la categoría
          child: Text(displayIcon, style: const TextStyle(fontSize: 24)),
        ),
        // 3. Usamos el título de la categoría
        title: Text(
          displayTitle,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostramos el subtítulo (descripción del gasto si existe)
            if (displaySubtitle.isNotEmpty && !isIncome) ...[
              Text(
                displaySubtitle,
                style: AppTextStyles.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            // Siempre mostramos la fecha
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
