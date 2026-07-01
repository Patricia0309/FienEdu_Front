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
    required int incomePeriodId, // <-- 1. AÑADIDO (y hecho 'required')
    int? categoryId,
    DateTime? date,
    String? note,
  }) async {
    // Preparamos el cuerpo de la petición
    final Map<String, dynamic> data = {
      'amount': amount,
      'type': type.name, // .name convierte el enum a 'ingreso' o 'gasto'
      'income_period_id': incomePeriodId, // <-- 2. AÑADIDO
      if (categoryId != null) 'category_id': categoryId,
    };

    // Añadimos los campos opcionales si existen
    if (date != null) {
      data['ts'] = date.toUtc().toIso8601String();
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

  // 1. GET para obtener una sola transacción fresca del backend
  Future<Transaction> getTransactionById(int transactionId) async {
    try {
      // Hace la petición al endpoint: GET /transactions/{id}
      final response = await _apiService.get('/transactions/$transactionId');
      final responseData = json.decode(response.body);
      return Transaction.fromJson(responseData);
    } catch (e) {
      print('Error en getTransactionById: $e');
      throw Exception('No se pudieron cargar los detalles de la transacción.');
    }
  }

  // 2. PUT para actualizar la transacción
  Future<void> updateTransaction({
    required int transactionId,
    required double amount,
    required TransactionType type,
    required int? categoryId,
    required DateTime date,
    required String note,
  }) async {
    try {
      // Mapeamos los datos exactamente al esquema 'TransactionUpdate' del backend
      // Nota: El backend en Python usa 'ts' para la fecha según tus logs anteriores
      final Map<String, dynamic> data = {
        'amount': amount,
        'type': type == TransactionType.gasto ? 'gasto' : 'ingreso',
        'category_id': categoryId,
        'ts': date.toIso8601String(), // Validamos la fecha
        'description': note,
      };

      // Hace la petición: PUT /transactions/{id}
      await _apiService.put('/transactions/$transactionId', data);
      print('🔄 Transacción $transactionId editada con éxito en el servidor.');
    } catch (e) {
      print('Error en updateTransaction: $e');
      // Captura el error 404 del periodo si la fecha no coincide
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
