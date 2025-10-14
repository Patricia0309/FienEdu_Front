// lib/data/services/transaction_service.dart

import 'dart:convert';
import 'api_service.dart';
import '../../features/transactions/models/transaction_model.dart';

class TransactionService {
  final ApiService _apiService = ApiService();

  // --- CREAR UNA NUEVA TRANSACCIÓN ---
  Future<void> createTransaction({
    required double amount,
    required TransactionType type,
    required int categoryId,
    // La fecha y la nota son opcionales según tu schema
    DateTime? date,
    String? note,
  }) async {
    // Preparamos el cuerpo de la petición
    final Map<String, dynamic> data = {
      'amount': amount,
      'type': type.name, // .name convierte el enum a 'ingreso' o 'gasto'
      'category_id': categoryId,
    };

    // Añadimos los campos opcionales si existen
    if (date != null) {
      data['date'] = date.toIso8601String();
    }
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }

    // Hacemos la llamada a través de nuestro ApiService
    await _apiService.post('/transactions/', data);
  }

  // --- OBTENER LA LISTA DE TRANSACCIONES ---
  Future<List<Transaction>> getTransactions() async {
    final response = await _apiService.get('/transactions/');
    final List<dynamic> transactionListJson = json.decode(response.body);

    // Convertimos la lista de JSON a una lista de objetos Transaction
    return transactionListJson
        .map((json) => Transaction.fromJson(json))
        .toList();
  }
}
