import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/notifications/models/user_device_token_model.dart';
import './helpers/token_manager.dart';
import './helpers/device_info_helper.dart';
import 'repositories/user_device_tokens_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final fcmPushNotificationServiceProvider =
    Provider<FCMPushNotificationService>((ref) {
  return FCMPushNotificationService(ref);
});

class FCMPushNotificationService {
  final FCMTokenManager _fcmTokenManager = FCMTokenManager();
  final Ref ref;

  bool _initialized = false;

  // Temp to help with debugging - displaying current token
  String currentToken = '';

  FCMPushNotificationService(this.ref);

  Future<void> initialize() async {
    /// User must be logged in - otherwise we cannot initialize the service
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      debugPrint('User is not logged in');
      return;
    }
    if (_initialized) return;

    _initialized = true;

    // Set up token handling
    _fcmTokenManager.setupTokenRefreshListener(_onTokenUpdate);

    // Get initial token
    final token = await _fcmTokenManager.getCurrentToken();
    if (token != null) {
      currentToken = token;
      await _onTokenUpdate(token);
    }

    // Set up message handlers
    await _handleInitialMessage();
  }

  // TODO p0: handle token deletion when user signs out
  Future<void> deInitialize() async {
    _initialized = false;

    _fcmTokenManager.clearTokenRefreshListener();
  }

  // TODO p0: save token or update existing token row last used date
  // TODO p0: handle outdated tokens
  Future<void> _onTokenUpdate(String fcmToken) async {
    debugPrint('FCM token updated: $fcmToken');
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();

      final deviceId = deviceInfo.deviceId;
      final curUserId = curUser.id;

      final deviceToken = await ref
          .read(userDeviceTokensRepositoryProvider)
          .getDeviceTokenByDeviceIdAndUserId(
              deviceId: deviceId, userId: curUserId);

      if (deviceToken != null) {
        // Update fcm token if updated
        if (deviceToken.fcmToken != fcmToken) {
          await ref
              .read(userDeviceTokensRepositoryProvider)
              .updateItem(deviceToken.copyWith(fcmToken: fcmToken));
        }
      }
      // Create new device token if not exists
      else {
        await ref.read(userDeviceTokensRepositoryProvider).insertItem(
            UserDeviceTokenModel(
                deviceId: deviceId,
                userId: curUserId,
                fcmToken: fcmToken,
                platform: deviceInfo.platform,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()));
      }
    } catch (e) {
      debugPrint('Failed to save token to server: $e');
    }
  }

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
    Map<String, dynamic>? data,
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
