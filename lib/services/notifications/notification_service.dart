import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'notification_handlers.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService not overridden');
});

class NotificationService {
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    try {
      // Get the local timezone offset in minutes
      final offset = DateTime.now().timeZoneOffset.inMinutes;

      // Map the offset to a timezone name
      final timeZoneName = _timezoneNames[offset] ?? 'UTC';
      log('Local timezone: $timeZoneName');

      // Set the local timezone
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      log('Error getting local timezone: $e');
      // Fallback to UTC if there's an error
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Initialize settings for both platforms with the background handler
    await _notificationsPlugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings(
            '@mipmap/ic_launcher'), // default icon
        iOS: DarwinInitializationSettings(
          notificationCategories: [
            DarwinNotificationCategory(
              'demoCategory',
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain(
                  'task_reminder',
                  'It\'s almost Task Due Date!',
                  options: <DarwinNotificationActionOption>{
                    DarwinNotificationActionOption.foreground,
                  },
                ),
              ],
              options: <DarwinNotificationCategoryOption>{
                DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
              },
            )
          ],
        ),
      ),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Request permissions for Android
    if (Platform.isAndroid) {
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    // Request iOS notification permissions
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Schedule a notification
  ///
  /// The notification will be saved in shared preferences
  /// using the notificationType as prefix,
  /// DateTime.now().millisecondsSinceEpoch as key,
  /// and the elementId and scheduledDate as value
  Future<void> scheduleNotification({
    required Ref ref,
    required String elementId,
    required String notificationType,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Generate a unique ID for the notification
    // (use milliseconds since epoch to avoid collisions
    // and use %0x7FFFFFFF to avoid overflow,
    // since the notifications plugin uses int32 for the id)
    final id = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    ref.read(sharedPreferencesProvider).setString(
        '${notificationType}_notification_$id',
        jsonEncode({
          'element_id': elementId,
          'scheduled_date': scheduledDate.toIso8601String()
        }));

    log('Scheduled notification with id $id to notify at $scheduledDate');
  }

  // TODO p0: save changes to shared preferences when notifications are cancelled
  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    log('Cancelled notification with id $id');
  }

  // TODO p0: save changes to shared preferences when notifications are cancelled
  /// Cancel all scheduled notifications
  // Future<void> cancelAllNotifications() async {
  //   await _notificationsPlugin.cancelAll();
  //   log('Cancelled all notifications');
  // }

  /// Get pending notification requests
  ///
  /// Returns a list of records, where the first element is the element id
  /// and the third element is the pending notification request
  Future<List<(String, DateTime, PendingNotificationRequest)>>
      getPendingNotifications(Ref ref, String notificationType) async {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    final pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();

    return pendingNotifications.map((e) {
      final elementData = jsonDecode(sharedPreferences
          .getString('${notificationType}_notification_${e.id}')!);
      final elementId = elementData['element_id'].toString();
      final scheduledDate = DateTime.parse(elementData['scheduled_date']);

      return (elementId, scheduledDate, e);
    }).toList();
  }

  static const _platformDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'seren_ai_reminders',
      'Seren.ai',
      channelDescription:
          'Notifications for task reminders and updates from Seren AI',
    ),
    iOS: DarwinNotificationDetails(),
  );
}

// Maps timezone offsets (in minutes) to IANA timezone names.
// Used as a fallback since existing timezone packages were unreliable
// in providing correct timezone names.
const _timezoneNames = {
  // Negative offsets (West of UTC)
  -660: 'Pacific/Samoa', // UTC-11
  -600: 'Pacific/Honolulu', // UTC-10
  -540: 'America/Anchorage', // UTC-9
  -480: 'America/Los_Angeles', // UTC-8 (US Pacific)
  -420: 'America/Denver', // UTC-7 (US Mountain)
  -360: 'America/Chicago', // UTC-6 (US Central)
  -300: 'America/New_York', // UTC-5 (US Eastern)
  -240: 'America/Halifax', // UTC-4
  -210: 'America/St_Johns', // UTC-3:30
  -180: 'America/Sao_Paulo', // UTC-3
  -120: 'America/Noronha', // UTC-2
  -60: 'Atlantic/Cape_Verde', // UTC-1

  // UTC
  0: 'UTC', // UTC+0

  // Positive offsets (East of UTC)
  60: 'Europe/London', // UTC+1
  120: 'Europe/Paris', // UTC+2
  180: 'Europe/Moscow', // UTC+3
  210: 'Asia/Tehran', // UTC+3:30
  240: 'Asia/Dubai', // UTC+4
  270: 'Asia/Kabul', // UTC+4:30
  300: 'Asia/Tashkent', // UTC+5
  330: 'Asia/Kolkata', // UTC+5:30
  345: 'Asia/Kathmandu', // UTC+5:45
  360: 'Asia/Dhaka', // UTC+6
  390: 'Asia/Yangon', // UTC+6:30
  420: 'Asia/Bangkok', // UTC+7
  480: 'Asia/Shanghai', // UTC+8
  540: 'Asia/Tokyo', // UTC+9
  570: 'Australia/Darwin', // UTC+9:30
  600: 'Australia/Sydney', // UTC+10
  630: 'Australia/Adelaide', // UTC+10:30
  660: 'Asia/Magadan', // UTC+11
  720: 'Pacific/Auckland', // UTC+12
  765: 'Pacific/Chatham', // UTC+12:45
  780: 'Pacific/Tongatapu', // UTC+13
  840: 'Pacific/Kiritimati', // UTC+14
};
