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
      "description":
          "Obtén consejos personalizados y accede a microcontenidos.",
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Altura disponible de la zona útil (dentro del padding)
              final h = constraints.maxHeight;

              // Altura del logo responsive (entre 140 y 260 px aprox)
              final maxLogoHeight = h * 0.24; // 24% de alto visible
              final logoHeight = maxLogoHeight.clamp(140.0, 260.0);

              // Separación controlada entre logo y PageView
              final gap = (h * 0.012).clamp(8.0, 16.0);

              // Relación de espacio entre logo y PageView
              final logoFlex = 0; // usamos altura fija
              final pageFlex = 1; // el PageView toma el resto

              return Column(
                children: [
                  // 1) Botón Saltar (arriba a la derecha)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _showPrivacyModal,
                      child: const Text("Saltar"),
                    ),
                  ),

                  // 2) Centro: Logo + PageView
                  Expanded(
                    child: Column(
                      children: [
                        // Logo responsive
                        SizedBox(
                          height: logoHeight,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/img/svg/Logo.svg',
                              height: logoHeight, // asegura ajuste
                              fit: BoxFit.contain,
                              // semanticsLabel: 'FinEdu Logo',
                            ),
                          ),
                        ),

                        SizedBox(height: gap),

                        // PageView ocupa el resto, pero con padding superior pequeño
                        Expanded(
                          flex: pageFlex,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                            ), // reduce separación interna
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _onboardingData.length,
                              onPageChanged: (page) =>
                                  setState(() => _currentPage = page),
                              itemBuilder: (context, index) => OnboardingPageContent(
                                iconData:
                                    _onboardingData[index]['icon'] as IconData,
                                title:
                                    _onboardingData[index]['title'] as String,
                                description:
                                    _onboardingData[index]['description']
                                        as String,

                                // >>> Ajusta padding interno de cada página para que el icono
                                //     quede más cerca del logo (depende de tu OnboardingPageContent)
                                topPadding:
                                    0, // <-- agrega este parámetro en tu widget
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3) Controles inferiores
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 15),

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
              );
            },
          ),
        ),
      ),
    );
  }
}
