import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/notifications/models/push_notification_model.dart';
import 'package:seren_ai_flutter/services/notifications/repositories/push_notifications_repository.dart';
import 'package:seren_ai_flutter/services/notifications/services/fcm_push_notification_service_provider.dart';

final log = Logger('TaskNotificationService');

final taskNotificationServiceProvider =
    Provider<TaskNotificationService>((ref) {
  return TaskNotificationService(ref);
});

class TaskNotificationService {
  final Ref ref;

  TaskNotificationService(this.ref);

  Future<void> handleTaskFieldUpdate({
    required String taskId,
    required TaskFieldEnum field,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null) return;

    // if old and new value same, do not send notification
    if (oldValue == newValue) return;

    String title;
    String body;

    final context = ref.read(navigationServiceProvider).context;

    switch (field) {
      case TaskFieldEnum.status:
        final oldStatus = oldValue as StatusEnum?;
        final newStatus = newValue as StatusEnum?;
        title = AppLocalizations.of(context)!.taskStatusUpdated;
        body = AppLocalizations.of(context)!.taskStatusUpdatedBody(
          task.name,
          oldStatus?.toHumanReadable(context) ?? 'none',
          newStatus?.toHumanReadable(context) ?? 'none',
        );
      case TaskFieldEnum.priority:
        final oldPriority = oldValue as PriorityEnum?;
        final newPriority = newValue as PriorityEnum?;
        title = AppLocalizations.of(context)!.taskPriorityUpdated;
        body = AppLocalizations.of(context)!.taskPriorityUpdatedBody(
          task.name,
          oldPriority?.toHumanReadable(context) ?? 'none',
          newPriority?.toHumanReadable(context) ?? 'none',
        );
      case TaskFieldEnum.name:
        title = AppLocalizations.of(context)!.taskNameUpdated;
        body = AppLocalizations.of(context)!.taskNameUpdatedBody(
          oldValue ?? '',
          task.name,
        );
      default:
        log.severe('Unknown task field update: $field');
        return;
    }

    // Get all task assignees
    final assignments = await ref
        .read(taskUserAssignmentsRepositoryProvider)
        .getTaskAssignments(taskId: taskId);

    final recipients = assignments.map((a) => a.userId).toList();

    // Add task author if not already included
    if (!recipients.contains(task.authorUserId)) {
      recipients.add(task.authorUserId);
    }

    // Remove current user
    final curUser = ref.read(curUserProvider).value;
    if (curUser != null) {
      recipients.removeWhere((id) => id == curUser.id);
    }

    if (recipients.isEmpty) return;

    final notificationData = TaskUpdateNotificationData(
      taskId: taskId,
      updateType: field,
    );

    final pushNotification = PushNotificationModel(
      userIds: recipients,
      referenceId: taskId,
      referenceType: notificationData.type,
      notificationTitle: title,
      notificationBody: body,
      sendAt: DateTime.now(),
      data: notificationData,
    );

    final pushNotificationId = await ref
        .read(pushNotificationsRepositoryProvider)
        .insertImmediately(pushNotification);

    await ref
        .read(fcmPushNotificationServiceProvider)
        .sendNotification(pushNotificationId);
  }

  Future<void> handleTaskAssignmentChange({
    required String taskId,
    required String affectedUserId,
    required bool isAssignment,
  }) async {
    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null) return;

    // For assignments, we only notify:
    // 1. The affected user (being assigned/unassigned)
    // 2. The task author (if different from current user)
    final recipients = <String>[affectedUserId];

    // TODO p2: create separate notification for task author to know who is being assigned/unassigned to their task!

    // // Add task author if not the current user
    // final curUser = ref.read(curUserProvider).value;
    // if (curUser != null && task.authorUserId != curUser.id) {
    //   recipients.add(task.authorUserId);
    // }

    if (recipients.isEmpty) return;

    final context = ref.read(navigationServiceProvider).context;

    final title = isAssignment
        ? AppLocalizations.of(context)!.newTaskAssignment
        : AppLocalizations.of(context)!.taskUnassignment;
    final body = isAssignment
        ? AppLocalizations.of(context)!.newTaskAssignmentBody(task.name)
        : AppLocalizations.of(context)!.taskUnassignmentBody(task.name);

    final notificationData = TaskAssignmentNotificationData(
      taskId: taskId,
      isAssignment: isAssignment,
    );

    final pushNotification = PushNotificationModel(
      userIds: recipients,
      referenceId: taskId,
      referenceType: notificationData.type,
      notificationTitle: title,
      notificationBody: body,
      sendAt: DateTime.now(),
      data: notificationData,
    );

    final pushNotificationId = await ref
        .read(pushNotificationsRepositoryProvider)
        .insertImmediately(pushNotification);

    await ref
        .read(fcmPushNotificationServiceProvider)
        .sendNotification(pushNotificationId);

    await handleTaskReminder(taskId: taskId);
  }

  Future<void> handleNewComment({
    required String taskId,
    required TaskCommentModel comment,
  }) async {
    if (comment.content == null) return;

    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null) return;

    // Get all task assignees
    final assignments = await ref
        .read(taskUserAssignmentsRepositoryProvider)
        .getTaskAssignments(taskId: taskId);

    final recipients = assignments.map((a) => a.userId).toList();

    // Add task author if not already included
    if (!recipients.contains(task.authorUserId)) {
      recipients.add(task.authorUserId);
    }

    // Remove comment author
    recipients.removeWhere((id) => id == comment.authorUserId);

    if (recipients.isEmpty) return;

    final context = ref.read(navigationServiceProvider).context;

    final title = AppLocalizations.of(context)!.taskNewComment;
    final body = AppLocalizations.of(context)!.taskNewCommentBody(
      task.name,
      comment.content ?? '',
    );

    final notificationData = TaskCommentNotificationData(
      taskId: taskId,
    );

    final pushNotification = PushNotificationModel(
      userIds: recipients,
      referenceId: comment.id,
      referenceType: notificationData.type,
      notificationTitle: title,
      notificationBody: body,
      sendAt: DateTime.now(),
      data: notificationData,
    );

    final pushNotificationId = await ref
        .read(pushNotificationsRepositoryProvider)
        .insertImmediately(pushNotification);

    await ref
        .read(fcmPushNotificationServiceProvider)
        .sendNotification(pushNotificationId);
  }

  Future<void> handleTaskReminder({
    required String taskId,
  }) async {
    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null) return;

    final recipients = (await ref
            .read(taskUserAssignmentsRepositoryProvider)
            .getTaskAssignments(taskId: taskId))
        .map((a) => a.userId)
        .toList();

    final pushNotificationsRepository =
        ref.read(pushNotificationsRepositoryProvider);

    final currentReminderNotification =
        await pushNotificationsRepository.getSingleOrNull(
      "SELECT * FROM push_notifications WHERE reference_id = '$taskId' AND reference_type = ? AND is_sent = 0", // we should not delete the notification if it is already sent
      {
        'reference_type': 'task_reminder',
      },
    );

    if (currentReminderNotification != null) {
      await pushNotificationsRepository
          .deleteItem(currentReminderNotification.id);
    }

    final context = ref.read(navigationServiceProvider).context;

    final notificationData = TaskReminderNotificationData(
      taskId: taskId,
    );

    if (task.dueDate != null && task.reminderOffsetMinutes != null) {
      // We're using insertImmediately because the insertItem method is not properly working
      // it seems to be not recognizing referenceId as a String:
      // DartError: Exception: Failed to insert item into push_notifications: Remote error: Invalid argument (params[2]): Allowed parameters must either be null or bool, int, num, String or List<int>.: Instance of 'minified:v<dynamic>'
      await pushNotificationsRepository.insertImmediately(
        PushNotificationModel(
          userIds: recipients,
          referenceId: taskId,
          referenceType: notificationData.type,
          notificationTitle: AppLocalizations.of(context)!.taskReminder,
          notificationBody: AppLocalizations.of(context)!.taskReminderBody(
            task.name,
            task.dueDate!.toString(),
          ),
          sendAt: task.dueDate!
              .toUtc()
              .subtract(Duration(minutes: task.reminderOffsetMinutes!)),
          data: notificationData,
        ),
      );
    }
  }
}
