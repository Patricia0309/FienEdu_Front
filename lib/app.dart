import 'package:flutter/material.dart';
import 'common/routing/app_routes.dart';
import 'common/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/signin_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
import 'features/inicial_setup/screens/initial_setup_screen.dart';
import 'features/main_app/screens/main_screen.dart';
import 'common/routing/navigator_key.dart';

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final bool isLoggedIn;
  const MyApp({super.key, required this.isFirstTime, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fin Edu App',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,

      initialRoute: _getInitialRoute(),

      // Define la ruta inicial y el mapa de rutas
      routes: {
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.signin: (context) => const SignInScreen(),
        AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
        AppRoutes.initialSetup: (context) => const InitialSetupScreen(),
        AppRoutes.dashboard: (context) => const MainScreen(),
      },
    );
  }

  String _getInitialRoute() {
    if (isFirstTime) {
      return AppRoutes.onboarding;
    } else if (isLoggedIn) {
      return AppRoutes.dashboard;
    } else {
      return AppRoutes.welcome; // O AppRoutes.signin, según prefieras
    }
  }
}
