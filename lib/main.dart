import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'data/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  // 1. Siempre debe ser lo primero
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar zonas horarias (Indispensable para el recordatorio local)
  tz.initializeTimeZones();

  // 3. Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();

  // 4. LANZAR SERVICIOS DE NOTIFICACIÓN (Sin 'await' para evitar pantalla blanca)
  // Esto permite que el token se gestione de fondo mientras la app abre.
  notificationService.initialize().catchError((e) => print("Error en FCM: $e"));

  // 5. Configuración de SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Leemos si es la primera vez y si tiene sesión
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 6. Configuración de Idioma y Fechas
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  // --- LOG DE SEGURIDAD (Para que veas el token en consola sin bloquear) ---
  FirebaseMessaging.instance.getToken().then((token) {
    print("-------------------------------------------------");
    print("PATY, ESTE ES TU TOKEN: $token");
    print("-------------------------------------------------");
  });

  // 7. Arrancar la aplicación
  runApp(MyApp(isFirstTime: isFirstTime, isLoggedIn: isLoggedIn));
}
