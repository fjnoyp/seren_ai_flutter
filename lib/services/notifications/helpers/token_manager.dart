import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMTokenManager {
  final FirebaseMessaging _messaging;

  FCMTokenManager() : _messaging = FirebaseMessaging.instance;

  Future<String?> _getIOSToken() async {
    final settings = await _messaging.requestPermission(
      provisional: true,
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('iOS notification settings: ${settings.authorizationStatus}');

    final apnsToken = await _messaging.getAPNSToken();
    if (apnsToken == null) {
      debugPrint('APNS token not available');
      return null;
    }

    return _messaging.getToken();
  }

  Future<String?> _getWebToken() async {
    return _messaging.getToken(
      vapidKey:
          "BG-JKknk5IjnB9-HV___PxKpxXgVX0-jK8KbAZRk3aWOqfmUoNwZTeRBmdNAPasiG57KZYMY61uMi-RXAlc7-LQ",
    );
  }

  Future<String?> _getDefaultToken() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification settings: ${settings.authorizationStatus}');

    return _messaging.getToken();
  }

  Future<String?> getCurrentToken() async {
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

  void setupTokenRefreshListener(Function(String) onTokenRefresh) {
    _messaging.onTokenRefresh.listen(onTokenRefresh);
  }

  void clearTokenRefreshListener() {
    _messaging.onTokenRefresh.drain();
  }
}
