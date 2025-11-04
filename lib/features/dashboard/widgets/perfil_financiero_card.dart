// lib/features/dashboard/widgets/perfil_financiero_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';

class PerfilFinancieroCard extends StatelessWidget {
  final String profileName;
  final String description; // Mantenemos el nombre de la variable como 'description'

  const PerfilFinancieroCard({
    super.key,
    this.profileName = 'Calculando...',
    this.description = 'Analizando tus datos...', // Usará la 'justification'
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5)) ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tu perfil financiero', style: AppTextStyles.heading),
              Icon(Icons.track_changes_outlined, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 12),
          Chip(
            label: Text(profileName, style: AppTextStyles.small.copyWith(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue.shade100,
          ),
          const SizedBox(height: 8),
          // Muestra la 'justification' que viene del backend
          Text(description, style: AppTextStyles.body), 
        ],
      ),
    );
  }
}