import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. Agrega este import
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase y SharedPreferences
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  // 3. Leemos si el usuario ya inició sesión anteriormente
  // 1. ¿Es la primera vez? (Si no existe el valor, asumimos que SÍ es true)
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  // 2. ¿Ya tiene sesión iniciada?
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  // 3. Pasamos AMBOS valores a MyApp
  runApp(MyApp(isFirstTime: isFirstTime, isLoggedIn: isLoggedIn));
}
