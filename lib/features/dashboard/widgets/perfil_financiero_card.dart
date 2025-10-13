// lib/features/dashboard/widgets/perfil_financiero_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';

class PerfilFinancieroCard extends StatelessWidget {
  const PerfilFinancieroCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Reemplazamos Card con Container para tener más control
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Aquí está la magia de la sombra suave
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Color de la sombra muy suave
            blurRadius: 20, // Qué tan difuminada es
            spreadRadius: 2,  // Qué tanto se extiende
            offset: const Offset(0, 5), // Posición (un poco hacia abajo)
          ),
        ],
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
            label: Text('Equilibrado', style: AppTextStyles.small.copyWith(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue.shade100,
            side: BorderSide.none,
          ),
          const SizedBox(height: 8),
          Text('Mantienes un buen balance entre gastos e ingresos', style: AppTextStyles.body),
        ],
      ),
    );
  }
}