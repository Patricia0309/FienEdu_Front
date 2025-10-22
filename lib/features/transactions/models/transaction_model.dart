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
    final DateTime dateValue = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now();
    final TransactionType typeValue = json['type'] == 'ingreso' 
        ? TransactionType.ingreso 
        : TransactionType.gasto;
    final int categoryIdValue = json['category_id'] as int? ?? 0;
    final String descriptionValue = json['description'] as String? ?? '';


    return Transaction(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(
        json['date'],
      ), // Asumiendo que la API devuelve la fecha como un string ISO 8601
      type: json['type'] == 'ingreso'
          ? TransactionType.ingreso
          : TransactionType.gasto,
      categoryId: json['category_id'],
      description: descriptionValue,
    );
  }
}
