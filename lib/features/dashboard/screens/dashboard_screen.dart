import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../transactions/widgets/new_transaction_modal.dart';
import '../widgets/dashboard_actions_grid.dart';
import '../widgets/perfil_financiero_card.dart';
import '../widgets/total_mes_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showNewTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF4F772D).withOpacity(0.82),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30), // Redondea solo los bordes de abajo
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola,', style: AppTextStyles.body.copyWith(color: Colors.white70)),
            Text('Paty 👋', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SvgPicture.asset('assets/Logo/1.svg', height: 40, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          ),
        ],
      ),
      // El body ahora es una simple lista de nuestros nuevos componentes
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.background, // Color de fondo general
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TotalMesCard(),
                SizedBox(height: 16),
                PerfilFinancieroCard(),
                SizedBox(height: 16),
                DashboardActionsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}