import 'package:flutter/material.dart';
import 'common/routing/app_routes.dart';
import 'common/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/signin_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
//import 'features/initial_setup/screens/initial_setup_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fin Edu App',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,

      // Define la ruta inicial y el mapa de rutas
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.welcome: (context) =>
            const WelcomeScreen(), // <-- Ruta actualizada
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.signin: (context) => const SignInScreen(),
        AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
        //AppRoutes.initialSetup: (context) => const InitialSetupScreen(),
      },
    );
  }
}
