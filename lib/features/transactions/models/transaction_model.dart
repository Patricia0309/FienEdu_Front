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
      // description puede ser opcional
    );
  }
}
