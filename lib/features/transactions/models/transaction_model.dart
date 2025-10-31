// lib/features/transactions/models/transaction_model.dart

enum TransactionType { gasto, ingreso }

class Transaction {
  final int id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final int categoryId;

  const Transaction({
    required this.id,
    this.description = '',
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
  });

  // --- CONSTRUCTOR CORREGIDO Y A PRUEBA DE NULOS ---
  factory Transaction.fromJson(Map<String, dynamic> json) {
    
    // Lee 'amount' de forma segura
    final double amountValue = (json['amount'] as num?)?.toDouble() ?? 0.0;
    
    // Lee 'date' de forma segura
    final DateTime dateValue = DateTime.tryParse(json['ts'] as String? ?? '') ?? DateTime.now();
    
    // Lee 'type' de forma segura
    final String typeString = json['type'] as String? ?? 'gasto'; // Asume 'gasto' si es nulo
    final TransactionType typeValue = typeString == 'ingreso' 
        ? TransactionType.ingreso 
        : TransactionType.gasto;
        
    // Lee 'category_id' de forma segura
    final int categoryIdValue = json['category_id'] as int? ?? 0; // Asume 0 o una ID 'desconocida'

    // Lee 'description' de forma segura
    final String descriptionValue = json['note'] as String? ?? ''; // Tu backend usa 'note'

    return Transaction(
      id: json['id'] as int? ?? 0, // Lee 'id' de forma segura
      amount: amountValue,
      date: dateValue,
      type: typeValue,
      categoryId: categoryIdValue,
      description: descriptionValue,
    );
  }
}