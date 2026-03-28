// lib/features/analysis/models/recommendation_model.dart
import 'dart:convert';

class Recommendation {
  final String type;
  final String title;
  final String body;

  Recommendation({required this.type, required this.title, required this.body});

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? 'Recomendación',
      body: json['body'] as String? ?? 'No hay detalles.',
    );
  }
}
