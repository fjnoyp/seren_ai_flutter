import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void localNotificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  log('Notification tapped in background: ${notificationResponse.payload}');

  // You can handle different actions based on the notificationResponse.actionId
  switch (notificationResponse.actionId) {
    default:
    // Handle default tap
  }
}
