import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';
import 'package:seren_ai_flutter/services/notifications/services/fcm_remote_message_handler.dart';

/// Handles FCM push notifications and their navigation
/// This includes:
/// 1. Background message handling
/// 2. Foreground message display
/// 3. Navigation when notifications are clicked
class FCMPushNotificationHandler {
  // Singleton instance
  static final FCMPushNotificationHandler instance =
      FCMPushNotificationHandler._();

  final _navigationQueue = <RemoteMessage>[];
  WidgetRef? _ref;

  // Private constructor
  FCMPushNotificationHandler._();

  /// Register Firebase message listeners
  /// Must be called from main.dart before any providers are initialized
  void registerMessageListeners(
      GlobalKey<ScaffoldMessengerState> messengerKey) {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessage
        .listen((msg) => _handleForegroundMessage(msg, messengerKey));
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
  }

  /// Set up navigation capabilities
  /// Must be called from app.dart after provider scope is ready
  void setupNavigation(WidgetRef ref) {
    _ref = ref;
    // Process any queued notifications
    for (final message in _navigationQueue) {
      _processNavigation(message, ref);
    }
    _navigationQueue.clear();
  }

  /// Called when FCM message is received in background (NOT CLICKED)
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Must initialize Firebase here because this runs in isolated context
    await Firebase.initializeApp();

    debugPrint('Background message received: ${message.data}');
    // Can only do background tasks - no UI or state access
  }

  /// Handle foreground messages by showing a snackbar
  void _handleForegroundMessage(
    RemoteMessage message,
    GlobalKey<ScaffoldMessengerState> messengerKey,
  ) {
    debugPrint('Foreground message received: ${message.data}');
    debugPrint('Notification Title: ${message.notification?.title}');
    debugPrint('Notification Body: ${message.notification?.body}');

    if (message.notification != null) {
      // Calculate duration based on content length
      int titleLength = message.notification?.title?.length ?? 0;
      int bodyLength = message.notification?.body?.length ?? 0;
      int durationInSeconds = (titleLength + bodyLength) ~/ 10 + 2;

      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: GestureDetector(
            onTap: () => _handleNotificationClick(message),
            child: Column(
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
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(
            seconds: durationInSeconds.clamp(3, 10),
          ),
        ),
      );
    }
  }

  /// Handle notification click or tap
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('Handling notification click: ${message.data}');
    if (_ref != null) {
      _processNavigation(message, _ref!);
    } else {
      debugPrint('Provider scope not ready, queueing notification');
      _navigationQueue.add(message);
    }
  }

  /// Process navigation using the notification handler
  Future<void> _processNavigation(RemoteMessage message, WidgetRef ref) async {
    debugPrint('Handling notification open: ${message.data}');

    final notificationData = NotificationData.fromJson(message.data);
    if (notificationData == null) {
      debugPrint('Unknown notification type: ${message.data["type"]}');
      return;
    }

    await NotificationDataHandler.handleNotificationOpen(notificationData, ref);
  }
}
