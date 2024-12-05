import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';
import 'package:seren_ai_flutter/services/notifications/models/notification_model.dart';
import 'package:seren_ai_flutter/services/notifications/notification_service.dart';

import 'dart:developer' as dev;

final taskNotificationsServiceProvider = Provider<bool>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref
        .read(_taskNotificationsRepositoryProvider)
        .watchUserViewableTasksNotifications(userId: userId),
  ).listen((notifications) async {
    // TODO: only replace notifications that have changed instead of cancelling all and scheduling all
    await notificationService.cancelAllNotifications();
    dev.log('Cancelled all notifications');
    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i].scheduledDate.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(notifications[i]);
      }
    }
  });
  return true;
});

final _taskNotificationsRepositoryProvider =
    Provider<TaskNotificationsRepository>((ref) {
  return TaskNotificationsRepository(ref.watch(dbProvider));
});

class TaskNotificationsRepository extends BaseRepository<NotificationModel> {
  const TaskNotificationsRepository(super.db);

  // TODO: Consider implementing column-specific change detection to optimize performance.
  // This would involve modifying the BaseRepository to trigger updates only when relevant columns change,
  // rather than any change in the watched tables. This can help reduce unnecessary processing and improve efficiency.
  @override
  Set<String> get watchTables => {'task_reminders', 'projects'};
  // obs.: we don't watch tasks for now because we're already updating the notification when the task changes

  @override
  NotificationModel fromJson(Map<String, dynamic> json) {
    final notificationJson = {
      'id': json['id'],
      'scheduled_date': json['scheduled_date'],
      'title': 'Task Reminder',
      'body':
          'Task ${json['task_name']} is due in ${json['reminder_offset_minutes']} minutes',
    };

    return NotificationModel.fromJson(notificationJson);
  }

  // Watch notifications of viewable tasks for a user (tasks where they are assigned to the project or are the author)
  Stream<List<NotificationModel>> watchUserViewableTasksNotifications({
    required String userId,
  }) {
    return watch(
      TaskQueries.userViewableTasksNotificationsQuery,
      {
        'user_id': userId,
        'author_user_id': userId,
      },
    );
  }

  // Get notifications of viewable tasks for a user (tasks where they are assigned to the project or are the author)
  Future<List<NotificationModel>> getUserViewableTasksNotifications({
    required String userId,
  }) async {
    return get(
      TaskQueries.userViewableTasksNotificationsQuery,
      {
        'user_id': userId,
        'author_user_id': userId,
      },
    );
  }
}
