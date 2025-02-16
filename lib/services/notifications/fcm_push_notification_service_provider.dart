import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import './helpers/token_manager.dart';
import './helpers/device_info_helper.dart';
import './repositories/device_tokens_repository.dart';

final fcmPushNotificationServiceProvider =
    Provider<FCMPushNotificationService>((ref) {
  return FCMPushNotificationService(ref);
});

class FCMPushNotificationService {
  final FCMTokenManager _tokenManager = FCMTokenManager();
  final Ref ref;

  bool _initialized = false;

  // Temp to help with debugging - displaying current token
  String currentToken = '';

  FCMPushNotificationService(this.ref);

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
    _tokenManager.setupTokenRefreshListener(_onTokenUpdate);

    // Get initial token
    final token = await _tokenManager.getCurrentToken();
    if (token != null) {
      currentToken = token;
      await _onTokenUpdate(token);
    }
  }

  // TODO p0: save token or update existing token row last used date
  // TODO p0: handle outdated tokens
  Future<void> _onTokenUpdate(String token) async {
    debugPrint('FCM token updated: $token');
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();

      // final userId = _repository.getCurrentUserId();
      // if (userId == null) {
      //   debugPrint('No user logged in, skipping token update');
      //   return;
      // }

      // await _repository.upsertToken({
      //   'user_id': userId,
      //   'device_id': deviceInfo['device_id'],
      //   'fcm_token': token,
      //   'device_name': deviceInfo['device_name'],
      //   'device_model': deviceInfo['device_model'],
      //   'platform': deviceInfo['platform'],
      //   'app_version': deviceInfo['app_version'],
      //   'last_used_at': DateTime.now().toIso8601String(),
      //   'is_active': true,
      // });
    } catch (e) {
      debugPrint('Failed to save token to server: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    // TODO p0: check if this is working and how it might be used ...
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      //_handleMessage(initialMessage);
      debugPrint('Initial message: ${initialMessage.data}');
    }
  }

  // ATTENTION - YOU CANNOT RUN ANY FCM MESSAGE LISTENER IN A PROVDIER THAT IS INITIALIZED IN APP AND NOT IN MAIN.DART
}
