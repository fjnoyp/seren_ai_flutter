import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/notifications/fcm_push_notification_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_data.dart';

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

    switch (field) {
      case TaskFieldEnum.status:
        final oldStatus = oldValue as StatusEnum?;
        final newStatus = newValue as StatusEnum?;
        title = 'Task Status Updated';
        body =
            'Task "${task.name}" was updated from ${oldStatus?.name ?? 'none'} to ${newStatus?.name ?? 'none'}';
      case TaskFieldEnum.priority:
        final oldPriority = oldValue as PriorityEnum?;
        final newPriority = newValue as PriorityEnum?;
        title = 'Task Priority Updated';
        body =
            'Task "${task.name}" priority changed from ${oldPriority?.name ?? 'none'} to ${newPriority?.name ?? 'none'}';
      case TaskFieldEnum.name:
        final oldName = oldValue as String?;
        title = 'Task Name Updated';
        body = 'Task name changed from "${oldName ?? ''}" to "${task.name}"';
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

    await ref.read(fcmPushNotificationServiceProvider).sendNotification(
          userIds: recipients,
          title: title,
          body: body,
          data: TaskUpdateNotificationData(
            taskId: taskId,
            updateType: field,
          ),
        );
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

    final title = isAssignment ? 'New Task Assignment' : 'Task Unassignment';
    final body = isAssignment
        ? 'You have been assigned to task "${task.name}"'
        : 'You have been removed from task "${task.name}"';

    await ref.read(fcmPushNotificationServiceProvider).sendNotification(
          userIds: recipients,
          title: title,
          body: body,
          data: TaskAssignmentNotificationData(
            taskId: taskId,
            isAssignment: isAssignment,
          ),
        );
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

    final title = 'New Comment on Task';
    final body = 'New comment on task "${task.name}": ${comment.content}';

    await ref.read(fcmPushNotificationServiceProvider).sendNotification(
          userIds: recipients,
          title: title,
          body: body,
          data: TaskCommentNotificationData(
            taskId: taskId,
          ),
        );
  }
}
