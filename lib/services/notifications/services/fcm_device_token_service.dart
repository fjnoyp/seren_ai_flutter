import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/notifications/helpers/device_info_helper.dart';
import 'package:seren_ai_flutter/services/notifications/models/user_device_token_model.dart';
import 'package:seren_ai_flutter/services/notifications/repositories/user_device_tokens_repository.dart';
import 'package:seren_ai_flutter/services/notifications/helpers/token_manager.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';

final fcmDeviceTokenServiceProvider = Provider<FCMDeviceTokenService>((ref) {
  return FCMDeviceTokenService(ref);
});

class FCMDeviceTokenService {
  final Ref ref;
  final FCMTokenManager _fcmTokenManager = FCMTokenManager();
  bool _initialized = false;

  // Temp to help with debugging - displaying current token
  String currentToken = '';

  FCMDeviceTokenService(this.ref);

  /// Initialize FCM token management for the current user
  Future<void> initialize() async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      debugPrint('User is not logged in');
      return;
    }
    if (_initialized) return;

    _initialized = true;

    // Set up token refresh handling
    _fcmTokenManager.setupTokenRefreshListener(_onTokenRefresh);

    // Get and handle initial token
    final token = await _fcmTokenManager.getCurrentToken();
    if (token != null) {
      currentToken = token;
      await _addCurrentDeviceToken(token);
    }
  }

  /// Clean up FCM token management when user logs out
  Future<void> deInitialize() async {
    if (!_initialized) return;

    final curUser = ref.read(curUserProvider).value;
    if (curUser != null) {
      await removeCurrentDeviceToken();
    }

    _initialized = false;
    _fcmTokenManager.clearTokenRefreshListener();
  }

  /// Add the current device's FCM token for the current user
  Future<void> _addCurrentDeviceToken(String fcmToken) async {
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      final deviceId = deviceInfo.deviceId;

      final existingToken = await ref
          .read(userDeviceTokensRepositoryProvider)
          .getDeviceTokenByDeviceIdAndUserId(
            deviceId: deviceId,
            userId: curUser.id,
          );

      if (existingToken != null) {
        // Update fcm token if changed
        if (existingToken.fcmToken != fcmToken) {
          await ref.read(userDeviceTokensRepositoryProvider).updateItem(
                existingToken.copyWith(
                  fcmToken: fcmToken,
                  updatedAt: DateTime.now(),
                ),
              );
        }
      } else {
        // Create new device token
        await ref.read(userDeviceTokensRepositoryProvider).insertItem(
              UserDeviceTokenModel(
                deviceId: deviceId,
                userId: curUser.id,
                fcmToken: fcmToken,
                platform: deviceInfo.platform,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
      }
    } catch (e) {
      debugPrint('Failed to add device token: $e');
      rethrow;
    }
  }

  /// Remove the current device's FCM token for the current user
  Future<void> removeCurrentDeviceToken() async {
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      final deviceId = deviceInfo.deviceId;

      final existingToken = await ref
          .read(userDeviceTokensRepositoryProvider)
          .getDeviceTokenByDeviceIdAndUserId(
            deviceId: deviceId,
            userId: curUser.id,
          );

      if (existingToken != null) {
        await ref
            .read(userDeviceTokensRepositoryProvider)
            .deleteItem(existingToken.id);
      }
    } catch (e) {
      debugPrint('Failed to remove device token: $e');
      rethrow;
    }
  }

  /// Handle FCM token refresh events
  Future<void> _onTokenRefresh(String fcmToken) async {
    debugPrint('FCM token refreshed: $fcmToken');
    try {
      await _addCurrentDeviceToken(fcmToken);
    } catch (e) {
      debugPrint('Failed to handle token refresh: $e');
      rethrow;
    }
  }
}
