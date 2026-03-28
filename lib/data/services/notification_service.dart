// lib/data/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart'; // To send the token to the backend
import '../../common/routing/navigator_key.dart'; // For navigation on tap
import '../../common/routing/app_routes.dart';   // For navigation routes
import 'package:flutter/material.dart';         // For showing alerts         

// Optional: Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, initialize Firebase first.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Not always needed for just FCM
  print("Handling a background message: ${message.messageId}");
  // You can perform background tasks here based on the message data
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    print("Initializing Notification Service...");
    // Request permission (iOS & Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Set to true if you want silent notifications initially
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted.');
      await _setupToken();
      _setupForegroundMessageHandler();
      _setupBackgroundMessageHandler();
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Notification permission granted provisionally.');
      await _setupToken();
      _setupForegroundMessageHandler();
      _setupBackgroundMessageHandler();
    } else {
      print('User declined or has not accepted notification permission.');
    }
  }

  Future<void> _setupToken() async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print("Firebase Messaging Token: $fcmToken");
        await _sendTokenToBackend(fcmToken);
        // Listen for token changes
        _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);
      } else {
        print("Failed to get FCM token.");
      }
    } catch (e) {
      print("Error getting/setting up FCM token: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      print("Sending FCM token to backend...");
      // Make sure this endpoint exists in your backend (e.g., in students.py)
      await _apiService.put('/students/me/fcm-token', {'fcm_token': token});
      print("FCM token sent successfully.");
    } catch (e) {
      print("Error sending FCM token to backend: $e");
      // Handle error, maybe retry later?
    }
  }

  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message received!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message notification: ${message.notification!.title} / ${message.notification!.body}');
        // Show a simple alert dialog when the app is open
        // You might want a more sophisticated in-app notification UI
        final context = navigatorKey.currentState?.overlay?.context;
        if (context != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(message.notification!.title ?? "Notification"),
              content: Text(message.notification!.body ?? ""),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  void _setupBackgroundMessageHandler() {
    // Handles notification tap when app is in background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped (app in background)!');
      print('Message data: ${message.data}');
      // Example: Navigate to a specific screen based on data
      // final screen = message.data['screen'];
      // if (screen == 'transactions' && navigatorKey.currentState != null) {
      //   navigatorKey.currentState!.pushNamed(AppRoutes.transactions); // Define this route
      // }
    });

    // Handles notification tap when app is terminated
    // This requires getting the initial message when the app starts
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Notification tapped (app terminated)!');
        print('Initial message data: ${message.data}');
        // Handle initial navigation based on message data here
      }
    });

    // Set the background handler (for data-only messages when app is terminated/background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}