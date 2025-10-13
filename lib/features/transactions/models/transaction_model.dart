enum TransactionType { gasto, ingreso }

class Transaction {
  final String category;
  final String icon; // Usaremos emojis por ahora
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;

  const Transaction({
    required this.category,
    required this.icon,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
}