import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../../common/routing/navigator_key.dart';
import '../../common/routing/app_routes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 🔹 Inicialización general
  Future<void> initialize() async {
    print("🔔 Inicializando servicio de notificaciones...");

    // Pedir permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _initLocalNotifications();
      await _setupToken();

      _setupForegroundHandler();
      _setupInteractionHandler();
      _setupBackgroundHandler();
    }
  }

  /// 🔹 Inicializar notificaciones locales (solo para mostrar en foreground)
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (route) => false,
        );
      },
    );
  }

  /// 🔹 Obtener y enviar token al backend
  Future<void> _setupToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        print("🔥 TOKEN FCM: $token");

        final prefs = await SharedPreferences.getInstance();
        final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          await _sendTokenToBackend(token);
        }

        // Escuchar refresh del token
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          final currentPrefs = await SharedPreferences.getInstance();
          if (currentPrefs.getBool('isLoggedIn') ?? false) {
            await _sendTokenToBackend(newToken);
          }
        });
      }
    } catch (e) {
      print("❌ Error obteniendo token: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiService.put('/students/me/fcm-token', {'fcm_token': token});
      print("✅ Token enviado al backend");
    } catch (e) {
      print("❌ Error enviando token: $e");
    }
  }

  /// 🔹 Notificación cuando la app está ABIERTA
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      print("📲 Notificación en foreground");

      final notification = message.notification;

      if (notification != null) {
        _localNotifications.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'General',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  /// 🔹 Cuando el usuario toca la notificación
  void _setupInteractionHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("👉 App abierta desde notificación");

      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
      );
    });
  }

  /// 🔹 Notificaciones en segundo plano
  void _setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
