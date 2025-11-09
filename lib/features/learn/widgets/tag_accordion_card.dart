// lib/features/learn/widgets/tag_accordion_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';
import '../models/microcontent_model.dart';
import 'topic_accordion_tile.dart'; // <-- Importa el widget que acabamos de crear

class TagAccordionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Microcontent> contentList;

  const TagAccordionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.contentList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        color: Colors.white,
        elevation: 0, // Sin sombra
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior:
            Clip.antiAlias, // Para que el ExpansionTile respete el borde
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

          // Encabezado del acordeón (Ahorro, Presupuesto, etc.)
          leading: Icon(icon, color: Colors.grey.shade700, size: 28),
          title: Text(
            title,
            style: AppTextStyles.heading.copyWith(fontSize: 18),
          ),
          subtitle: Text(
            '${contentList.length} temas',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),

          // Contenido (los sub-temas)
          children: [
            // Creamos una columna de sub-acordeones
            Column(
              children: contentList.map((content) {
                // Llama al widget anidado
                return TopicAccordionTile(content: content);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
