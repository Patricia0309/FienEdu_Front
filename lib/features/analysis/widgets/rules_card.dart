// lib/features/analysis/widgets/rules_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart'; // Ajusta esta ruta
import '../../../common/theme/app_text_styles.dart'; // Ajusta esta ruta
import '../models/apriori_rule_model.dart';

class RulesCard extends StatefulWidget {
  final List<AprioriRule> rules;
  const RulesCard({super.key, required this.rules});

  @override
  State<RulesCard> createState() => _RulesCardState();
}

class _RulesCardState extends State<RulesCard> {
  bool _isExpanded = false;
  final int _limit = 5; // El límite de 5 reglas que pediste

  // Esta es tu función _buildRuleRow, pero ahora vive aquí
  // y está adaptada para usar el modelo nuevo
  Widget _buildRuleRow(AprioriRule rule) {
    // Unimos las listas en un solo String
    final String antecedentsText = rule.antecedents.join(', ');
    final String consequentsText = rule.consequents.join(', ');

    // 1. Definimos los estilos que usaremos
    final normalStyle = AppTextStyles.body;
    final boldStyle = AppTextStyles.body.copyWith(fontWeight: FontWeight.bold);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary, // Asumo que tienes AppColors
            fontWeight: FontWeight.bold,
          ),
        ),
        // 2. Usamos RichText en lugar de Text
        Expanded(
          child: RichText(
            text: TextSpan(
              style: normalStyle, // Estilo por defecto para toda la línea
              children: <TextSpan>[
                TextSpan(text: 'Si gastas en '),
                // 3. Aplicamos el estilo negrita a los antecedentes
                TextSpan(text: antecedentsText, style: boldStyle),
                TextSpan(text: ', tiendes a gastar en '),
                // 4. Aplicamos el estilo negrita a las consecuencias
                TextSpan(text: consequentsText, style: boldStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos qué reglas mostrar
    final bool hasMore = widget.rules.length > _limit;
    final List<AprioriRule> displayedRules = hasMore && !_isExpanded
        ? widget.rules.take(_limit).toList()
        : widget.rules;

    // Este es tu Container original
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule, size: 24),
              const SizedBox(width: 12),
              Text('Reglas identificadas', style: AppTextStyles.heading),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.rules.isEmpty)
            Text(
              'Aún no hay suficientes datos para identificar reglas.',
              style: AppTextStyles.body,
            )
          else
            // Un Column para la lista de reglas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayedRules
                  .map(
                    (rule) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildRuleRow(rule),
                    ),
                  )
                  .toList(),
            ),

          // --- AQUÍ ESTÁ LA LÓGICA "VER MÁS" ---
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded
                      ? 'Ver menos'
                      : 'Ver más (${widget.rules.length - _limit} más)',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary, // Color de acento
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
