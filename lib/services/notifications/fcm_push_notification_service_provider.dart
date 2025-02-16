import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final fcmPushNotificationServiceProvider =
    Provider<FCMPushNotificationService>((ref) {
  return FCMPushNotificationService();
});

class FCMPushNotificationService {
  // TODO p2: switch to private - made public to show in android testing
  String? currentToken;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Set up token handling
    await _initializeToken();

    // Set up message handlers
    await _setupMessageHandlers();
  }

  Future<void> _initializeToken() async {
    // Set up refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _onTokenUpdate(newToken);
    }).onError((error) {
      debugPrint('FCM token refresh error: $error');
    });

    // Get initial token
    final token = await _getCurrentToken();
    if (token != null) {
      await _onTokenUpdate(token);
    }
  }

  Future<String?> _getCurrentToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _getIOSToken();
      } else if (kIsWeb) {
        return _getWebToken();
      } else {
        return _getDefaultToken();
      }
    } catch (error) {
      debugPrint('Error getting FCM token: $error');
      return null;
    }
  }

  Future<String?> _getIOSToken() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      provisional: true,
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('iOS notification settings: ${settings.authorizationStatus}');

    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken == null) {
      debugPrint('APNS token not available');
      return null;
    }

    return FirebaseMessaging.instance.getToken();
  }

  Future<String?> _getWebToken() async {
    return FirebaseMessaging.instance.getToken(
      vapidKey:
          "BG-JKknk5IjnB9-HV___PxKpxXgVX0-jK8KbAZRk3aWOqfmUoNwZTeRBmdNAPasiG57KZYMY61uMi-RXAlc7-LQ", // Replace with your VAPID key
    );
  }

  Future<String?> _getDefaultToken() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification settings: ${settings.authorizationStatus}');

    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _onTokenUpdate(String token) async {
    if (token == currentToken) return;
    currentToken = token;

    debugPrint('FCM token updated: $token');
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('user_push_tokens').upsert({
        'user_id': supabase.auth.currentUser?.id,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to save token to server: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Opened from foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.data}');
      if (message.notification != null) {
        debugPrint('Notification: ${message.notification}');
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Handling FCM message: ${message.data}');
    if (message.data['type'] != null) {
      switch (message.data['type']) {
        case 'chat':
          // Navigate to chat screen
          break;
        case 'task':
          // Navigate to task screen
          break;
        default:
          debugPrint('Unknown message type: ${message.data['type']}');
      }
    }
  }
}
