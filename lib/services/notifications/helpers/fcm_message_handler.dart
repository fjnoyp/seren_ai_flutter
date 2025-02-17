import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Handles all FCM message related functionality
/// This class is designed to be used from main.dart but keeps the implementation separate
class FCMMessageHandler {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  FCMMessageHandler({required this.scaffoldMessengerKey});

  /// Called when FCM message is received in background (NOT CLICKED)
  /// Must be registered in main.dart
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    // Must initialize Firebase here because this runs in isolated context
    await Firebase.initializeApp();

    debugPrint('Firebase Messaging Background Handler');
    debugPrint('Message: $message');

    // Can only do background tasks - no UI or state access
    // TODO: Implement any background processing needed
  }

  /// Handle app in background and message is clicked
  /// Must be registered in main.dart
  void onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Handling FCM message: ${message.data}');
    if (message.data['type'] != null) {
      switch (message.data['type']) {
        case 'chat':
          // TODO: Navigate to chat screen
          break;
        case 'task':
          // TODO: Navigate to task screen
          break;
        default:
          debugPrint('Unknown message type: ${message.data['type']}');
      }
    }
  }

  /// Handle foreground messages
  /// Must be registered in main.dart
  void onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data}');
    debugPrint('Notification Title: ${message.notification?.title}');
    debugPrint('Notification Body: ${message.notification?.body}');

    if (message.notification != null) {
      debugPrint('Notification: ${message.notification}');

      // Calculate duration based on the length of the title and body
      int titleLength = message.notification?.title?.length ?? 0;
      int bodyLength = message.notification?.body?.length ?? 0;
      int durationInSeconds = (titleLength + bodyLength) ~/ 10 +
          2; // Show for longer based on length

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.notification?.title != null)
                Text(
                  message.notification!.title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (message.notification?.body != null)
                Text(message.notification!.body!),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(
              seconds: durationInSeconds.clamp(
                  3, 10)), // Clamp duration between 3 and 10 seconds
        ),
      );
    }
  }

  /// Initialize all message handlers
  /// Must be called from main.dart
  static void initializeHandlers(FCMMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handler.onMessageOpenedApp);
    FirebaseMessaging.onMessage.listen(handler.onForegroundMessage);
  }
}
