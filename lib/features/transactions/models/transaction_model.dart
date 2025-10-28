enum TransactionType { gasto, ingreso }

class Transaction {
  final int id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final int categoryId;
  // Podríamos añadir más campos que devuelva el backend si es necesario

  const Transaction({
    required this.id,
    this.description = '',
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final double amountValue = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final DateTime dateValue =
        DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now();
    final int categoryIdValue = json['category_id'] as int? ?? 0;
    final String descriptionValue = json['description'] as String? ?? '';
    final String typeString =
        json['type'] as String? ?? 'gasto'; // Make type string safe
    final TransactionType typeValue = typeString == 'ingreso'
        ? TransactionType.ingreso
        : TransactionType.gasto;

    return Transaction(
      id: json['id'] as int? ?? 0,
      amount: amountValue,
      date: dateValue,
      type: typeValue,
      categoryId: categoryIdValue,
      description: descriptionValue,
    );
  }
}
