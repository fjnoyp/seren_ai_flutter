import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/notifications/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:developer' as dev;

final taskScheduleNotificationsServiceProvider = Provider((ref) {
  final notificationService = ref.read(notificationServiceProvider);

  CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref
        .read(tasksRepositoryProvider)
        .watchUserAssignedTasks(userId: userId),
  ).listen((tasks) async {
    // Get localizations from the current context when needed
    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) return;
    final localizations = AppLocalizations.of(context)!;

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
          title: localizations.taskReminder,
          body: localizations.taskReminderBody(
            task.name,
            task.reminderOffsetMinutes!,
          ),
          scheduledDate: scheduledDate,
        );
      }
    }
  });
});
