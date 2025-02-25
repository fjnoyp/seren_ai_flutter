import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';

/// Handles notification clicks and routes them to appropriate screens
class FCMRemoteMessageHandler {
  /// Handle a notification being opened/clicked
  static Future<void> handleNotificationOpen(
      RemoteMessage message, WidgetRef ref) async {
    debugPrint('Handling notification open: ${message.data}');

    final notificationData = NotificationData.fromJson(message.data);
    if (notificationData == null) {
      debugPrint('Unknown notification type: ${message.data["type"]}');
      return;
    }

    switch (notificationData) {
      case TaskNotificationData():
        await _handleTaskNotification(notificationData, ref);
      // Add other notification types here
    }
  }

  static Future<void> _handleTaskNotification(
      TaskNotificationData data, WidgetRef ref) async {
    final taskId = data.taskId;

    await ref.read(taskNavigationServiceProvider).openTask(
          initialTaskId: taskId,
        );
  }
}
