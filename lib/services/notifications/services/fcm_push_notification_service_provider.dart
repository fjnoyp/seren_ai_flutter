import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import '../helpers/token_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seren_ai_flutter/services/notifications/services/fcm_device_token_service.dart';

final fcmPushNotificationServiceProvider =
    Provider<FCMPushNotificationService>((ref) {
  return FCMPushNotificationService(ref);
});

class FCMPushNotificationService {
  final Ref ref;

  FCMPushNotificationService(this.ref);

  Future<void> _handleInitialMessage() async {
    // TODO p0: check if this is working and how it might be used ...
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      //_handleMessage(initialMessage);
      debugPrint('Initial message: ${initialMessage.data}');
    }
  }

  /// Sends a notification to specified users using the Supabase Edge Function
  ///
  /// [userIds] - List of user IDs to send the notification to
  /// [title] - The title of the notification
  /// [body] - The body text of the notification
  /// [data] - Optional map of additional data to send with the notification
  ///
  /// Returns a Map containing the success status and any error message
  Future<Map<String, dynamic>> sendNotification({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'send-notification',
        body: {
          'user_ids': userIds,
          'notification': {
            'title': title,
            'body': body,
          },
          if (data != null) 'data': data,
        },
      );

      if (response.status != 200) {
        debugPrint('Failed to send notification: ${response.data}');
        return {
          'success': false,
          'error': 'Failed to send notification: ${response.data}',
        };
      }

      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return {
        'success': false,
        'error': 'Error sending notification: $e',
      };
    }
  }

  // ATTENTION - YOU CANNOT RUN ANY FCM MESSAGE LISTENER IN A PROVIDER THAT IS INITIALIZED IN APP AND NOT IN MAIN.DART
}
