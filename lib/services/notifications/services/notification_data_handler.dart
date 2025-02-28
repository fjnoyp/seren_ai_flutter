import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';

/// Handles notification clicks and routes them to appropriate screens
class NotificationDataHandler {
  /// Handle a notification being opened/clicked
  static Future<void> handleNotificationOpen(
      NotificationData notificationData, WidgetRef ref) async {
    switch (notificationData) {
      case TaskNotificationData():
        await _handleTaskNotification(notificationData, ref);
      case UserInviteNotificationData():
        await _handleUserInviteNotification(notificationData, ref);
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

  static Future<void> _handleUserInviteNotification(
      UserInviteNotificationData data, WidgetRef ref) async {
    ref.read(navigationServiceProvider).navigateTo(
      AppRoutes.orgInvite.name,
      arguments: {'orgId': data.orgId},
    );
  }
}
