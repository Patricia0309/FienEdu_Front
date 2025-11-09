// lib/features/learn/widgets/topic_accordion_tile.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/microcontent_model.dart';

class TopicAccordionTile extends StatelessWidget {
  final Microcontent content;

  const TopicAccordionTile({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      backgroundColor: Colors.grey.shade50.withOpacity(0.5), // Fondo ligero
      // Encabezado (Usa 'title' de tu modelo)
      title: Text(
        content.title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      ),

      // ¡SIN 'subtitle'! Tu modelo no tiene 'readingTime'.
      // Lo quitamos para evitar errores.

      // Contenido (Usa 'body' de tu modelo)
      children: [
        Container(
          // Simplemente mostramos el 'body' como un solo texto
          padding: const EdgeInsets.fromLTRB(36, 0, 20, 20),
          width: double.infinity,
          child: Text(
            content.body,
            style: AppTextStyles.body.copyWith(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
