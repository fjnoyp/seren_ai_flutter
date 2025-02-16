import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:uuid/uuid.dart';

class DeviceInfo {
  final String deviceId;
  final String deviceModel;
  final String platform;

  DeviceInfo({
    required this.deviceId,
    required this.deviceModel,
    required this.platform,
  });
}

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const String _webDeviceIdKey = 'web_device_id';

  static Future<String> _getOrCreateWebDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_webDeviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_webDeviceIdKey, deviceId);
    }

    return deviceId;
  }

  static Future<DeviceInfo> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        final deviceId = await _getOrCreateWebDeviceId();

        return DeviceInfo(
          deviceId: deviceId,
          deviceModel:
              '${webInfo.browserName} on ${webInfo.platform ?? 'unknown'}',
          platform: 'web',
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final identifier = await UniqueIdentifier.serial ?? 'unknown';

        return DeviceInfo(
          deviceId: identifier,
          deviceModel: iosInfo.model,
          platform: 'ios',
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        final identifier = await UniqueIdentifier.serial ?? 'unknown';

        return DeviceInfo(
          deviceId: identifier,
          deviceModel: '${androidInfo.brand} ${androidInfo.model}',
          platform: 'android',
        );
      }

      // Default fallback
      return DeviceInfo(
        deviceId: DateTime.now().toIso8601String(),
        deviceModel: 'unknown',
        platform: defaultTargetPlatform.toString(),
      );
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return DeviceInfo(
        deviceId: DateTime.now().toIso8601String(),
        deviceModel: 'unknown',
        platform: 'unknown',
      );
    }
  }
}
