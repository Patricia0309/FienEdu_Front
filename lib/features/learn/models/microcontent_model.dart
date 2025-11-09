// lib/features/learn/models/microcontent_model.dart
import 'dart:convert';

class Microcontent {
  final int id;
  final String title;
  final String body; // <-- Cambiado de List<String> a String
  final String tag;

  Microcontent({
    required this.id,
    required this.title,
    required this.body, // <-- Cambiado
    required this.tag,
  });

  factory Microcontent.fromJson(Map<String, dynamic> json) {
    return Microcontent(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Sin Título',
      // --- ¡CAMBIO IMPORTANTE AQUÍ! ---
      // Lee el campo 'body' como un solo String
      body: json['body'] as String? ?? 'No hay descripción.',
      tag: json['tag'] as String? ?? 'general',
      // No hay 'reading_time' en tu JSON, así que lo quitamos
    );
  }
}
