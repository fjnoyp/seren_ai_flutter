import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/notifications/notification_service.dart';

import 'dart:developer' as dev;

final taskScheduleNotificationsServiceProvider = Provider<bool>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref
        .read(tasksRepositoryProvider)
        .watchUserViewableTasks(userId: userId),
  ).listen((tasks) async {
    // TODO: only replace notifications that have changed instead of cancelling and rescheduling all
    await notificationService.cancelAllNotifications();
    dev.log('Cancelled all notifications');
    for (final task
        in tasks.where((task) => task.reminderOffsetMinutes != null)) {
      final scheduledDate = task.dueDate!.toLocal().subtract(
        Duration(minutes: task.reminderOffsetMinutes!),
      );

      if (scheduledDate.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(
          id: tasks.indexOf(task),
          title: 'Task Reminder',
          body:
              'Task ${task.name} is due in ${task.reminderOffsetMinutes} minutes',
          scheduledDate: scheduledDate,
        );
      }
    }
  });
  return true;
});
