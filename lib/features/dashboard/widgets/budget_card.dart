// lib/features/dashboard/widgets/budget_card.dart

import 'package:flutter/material.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';

class BudgetCard extends StatelessWidget {
  final VoidCallback onSetBudgetTap; // Function to open the modal

  const BudgetCard({
    super.key,
    required this.onSetBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Presupuesto', style: AppTextStyles.heading),
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add, color: AppColors.accent1),
            label: Text(
              'Establecer presupuesto',
              style: AppTextStyles.body.copyWith(color: AppColors.accent1, fontWeight: FontWeight.w600),
            ),
            onPressed: onSetBudgetTap, // Call the function passed from Dashboard
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: AppColors.accent1,
              side: const BorderSide(color: AppColors.accent1, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}