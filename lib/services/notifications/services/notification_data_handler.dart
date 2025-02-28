import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_notifier_provider.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final invite = ref.read(curUserInvitesNotifierProvider).firstWhere(
          (invite) => invite.orgId == data.orgId,
          orElse: () => throw Exception('Invite not found'),
        );
    if (invite.status == InviteStatus.pending) {
      ref.read(navigationServiceProvider).navigateTo(
            AppRoutes.orgInvite.name,
            arguments: {'orgId': data.orgId},
          );
    } else {
      final context =
          ref.read(navigationServiceProvider).navigatorKey.currentContext!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.youHaveAlreadyAnsweredThisInvite,
          ),
        ),
      );
    }
  }
}
