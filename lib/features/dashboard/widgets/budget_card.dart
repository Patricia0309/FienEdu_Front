// lib/features/dashboard/widgets/budget_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- 1. AÑADE ESTE IMPORT PARA FECHAS
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../budgets/models/budget_status_model.dart';

class BudgetCard extends StatelessWidget {
  final VoidCallback onSetBudgetTap;
  final BudgetStatus? budgetStatus;
  const BudgetCard({
    super.key,
    required this.onSetBudgetTap,
    this.budgetStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Esta lógica ya estaba perfecta
    final bool hasActiveBudget = budgetStatus != null;
    final String buttonText = hasActiveBudget
        ? 'Editar presupuesto'
        : 'Establecer presupuesto';
    final IconData buttonIcon = hasActiveBudget
        ? Icons.edit_outlined
        : Icons.add;

    return Container(
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
          // --- TÍTULO (Sin cambios) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Presupuesto', style: AppTextStyles.heading),
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
            ],
          ),

          // --- 2. ¡CAMBIO VISUAL AQUÍ! ---
          // Si hay un presupuesto, mostramos los detalles
          if (hasActiveBudget) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'PRESUPUESTO:',
              // Formateamos el monto como moneda
              '\$${budgetStatus!.totalIncome.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'PERIODO:',
              // Formateamos las fechas
              '${DateFormat('dd/MM/yy').format(budgetStatus!.startDate)} - ${DateFormat('dd/MM/yy').format(budgetStatus!.endDate)}',
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Si no, dejamos el espacio original
            const SizedBox(height: 16),
          ],
          // --- FIN DEL CAMBIO ---

          // --- BOTÓN (Con corrección de icono) ---
          OutlinedButton.icon(
            // 3. CORRECCIÓN: Usamos el icono dinámico
            icon: Icon(buttonIcon, color: AppColors.accent1),
            label: Text(
              buttonText, // Texto dinámico
              style: AppTextStyles.body.copyWith(
                color: AppColors.accent1,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onSetBudgetTap, // Llama a la función del Dashboard
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: AppColors.accent1,
              side: const BorderSide(color: AppColors.accent1, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. WIDGET HELPER (para no repetir código y que se vea bien)
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary, // Color principal
            ),
            softWrap: true, // Para que el texto se ajuste si no cabe
          ),
        ),
      ],
    );
  }
}
