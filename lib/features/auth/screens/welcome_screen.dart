import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/routing/app_routes.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/secondary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              SvgPicture.asset('assets/img/svg/Logo.svg', height: 250),
              const SizedBox(height: 24),
              Text(
                'Bienvenid@ a FinEdu',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu aliada en educación financiera',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Crear cuenta',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: 'Ya tengo una cuenta',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.signin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
