// lib/features/analysis/models/apriori_rule_model.dart
import 'dart:convert';

class AprioriRule {
  // 1. Cambiados de String a List<String>
  final List<String> antecedents;
  final List<String> consequents;
  final double support;
  final double confidence;

  AprioriRule({
    required this.antecedents,
    required this.consequents,
    required this.support,
    required this.confidence,
  });

  factory AprioriRule.fromJson(Map<String, dynamic> json) {
    // 1. Obtenemos las listas de forma segura
    //    Si json['antecedents'] es null, lo convierte en []
    final antecedentsData = json['antecedents'] as List<dynamic>? ?? [];
    final consequentsData = json['consequents'] as List<dynamic>? ?? [];

    // 2. Convertimos cada item de la lista a String
    //    Esto también maneja si un item *dentro* de la lista es null
    final List<String> antecedentsList = antecedentsData
        .map((item) => item.toString())
        .toList();

    final List<String> consequentsList = consequentsData
        .map((item) => item.toString())
        .toList();

    // 3. Creamos la regla
    return AprioriRule(
      antecedents: antecedentsList,
      consequents: consequentsList,
      support: json['support']?.toDouble() ?? 0.0,
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }
}
