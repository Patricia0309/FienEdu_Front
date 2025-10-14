import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/theme/app_colors.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../dashboard/widgets/perfil_financiero_card.dart'; // Reutilizamos este widget
import '../widgets/gastos_categoria_card.dart';
import '../widgets/reglas_card.dart';
import '../widgets/tendencia_card.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header personalizado
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent2.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Análisis Financiero',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SvgPicture.asset(
                  'assets/img/svg/Logo.1.svg', // <-- TU LOGO AQUÍ
                  height: 50,
                  // Nota: Este colorFilter lo pintará de un solo color, si tu logo ya tiene colores, elimina esta línea.
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          // Contenido con scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  PerfilFinancieroCard(), // <-- ¡Widget reutilizado!
                  SizedBox(height: 16),
                  GastosCategoriaCard(),
                  SizedBox(height: 16),
                  TendenciaCard(),
                  SizedBox(height: 16),
                  ReglasCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
