import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/widgets/primary_button.dart';
import '../widgets/onboarding_page_content.dart';
import '../../../common/routing/app_routes.dart';
import '../widgets/privacy_policy_modal.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // TODO: Mueve estos datos a un modelo o a otro archivo si se vuelven complejos.
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "icon": Icons.wallet_outlined,
      "title": "Registra tus ingresos y gastos",
      "description": "Lleva el control de tu dinero de forma simple y rápida.",
    },
    {
      "icon": Icons.analytics_outlined,
      "title": "Analiza tus hábitos",
      "description": "FindEdu identifica patrones en tus gastos.",
    },
    {
      "icon": Icons.lightbulb_outline,
      "title": "Recibe recomendaciones y aprende",
      "description": "",
    },
  ];

  void _showPrivacyModal() async {
    // 'showModalBottomSheet' muestra nuestro widget desde abajo.
    // 'await' espera a que el modal se cierre y nos devuelve un valor.
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // Permite que el modal ocupe más pantalla
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Le damos una altura máxima del 90% de la pantalla
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: const PrivacyPolicyModal(),
        );
      },
    );

    // Si el resultado es 'true' (porque el usuario presionó 'Continuar'),
    if (result == true) {
      print(
        "Políticas aceptadas. Navegando a la pantalla de Registro/Login...",
      );
      // Usamos 'mounted' para asegurarnos de que el widget todavía está en pantalla
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Botón Saltar
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _showPrivacyModal,
                  child: Text("Saltar"),
                ),
              ),
              // ---LOGO ---
              const SizedBox(height: 5),
              SvgPicture.asset('assets/img/svg/Logo.svg', height: 220),
              const SizedBox(height: 10),
              // Contenido deslizable
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) => OnboardingPageContent(
                    // Pasa el ícono desde tu lista de datos
                    iconData:
                        _onboardingData[index]['icon']
                            as IconData, // <-- LÍNEA MODIFICADA
                    title: _onboardingData[index]['title'] as String,
                    description:
                        _onboardingData[index]['description'] as String,
                  ),
                ),
              ),
              // Indicadores (puntitos)
              // TODO: Extraer a su propio widget en onboarding/widgets/dot_indicator.dart
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 10,
                    width: _currentPage == index ? 25 : 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Botón principal reutilizable
              PrimaryButton(
                text: _currentPage == _onboardingData.length - 1
                    ? 'Comenzar'
                    : 'Siguiente',
                icon: _currentPage != _onboardingData.length - 1
                    ? const Icon(Icons.arrow_forward, size: 18)
                    : null,
                onPressed: () {
                  if (_currentPage == _onboardingData.length - 1) {
                    _showPrivacyModal();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _showPrivacyModal,
                child: const Text('Política de Privacidad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
