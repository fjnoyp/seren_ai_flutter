import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/notifications/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO p3: the stream subscription is being recreated every time the provider is read, causing multiple listeners.
// But when we use autoDispose, the provider is being disposed too quickly and the stream is not being listened to.
// We need to find a way to listen to the stream and not recreate the subscription every time the provider is read.
// For now, this solution is working (but it's repeatdly cancelling and rescheduling notifications 2-3 times per reminder update)

final taskScheduleNotificationsServiceProvider = Provider((ref) {
  final notificationService = ref.read(notificationServiceProvider);

  CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref
        .read(tasksRepositoryProvider)
        .watchUserAssignedTasks(userId: userId),
  ).listen((tasks) async {
    final tasksToSchedule =
        tasks.where((task) => task.reminderOffsetMinutes != null).toList();

    // Get localizations from the current context when needed
    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) return;
    final localizations = AppLocalizations.of(context)!;

    final notifications =
        await notificationService.getPendingNotifications(ref, 'task');

    // Remove notifications that are no longer valid
    for (final (taskId, scheduledDate, notification) in notifications) {
      if (tasksToSchedule.any((task) => task.id == taskId)) {
        final task = tasksToSchedule.firstWhere((task) => task.id == taskId);

        // Compare dates ignoring milliseconds to avoid precision issues
        final existingSchedule =
            scheduledDate.copyWith(millisecond: 0, microsecond: 0);
        final newSchedule = task.dueDate!
            .subtract(Duration(minutes: task.reminderOffsetMinutes!))
            .copyWith(millisecond: 0, microsecond: 0);

        if (existingSchedule == newSchedule) {
          // If scheduled date matches, remove from tasksToSchedule (already scheduled)
          tasksToSchedule.removeWhere((t) => t.id == taskId);
        } else {
          // If scheduled date does not match, cancel the notification
          await notificationService.cancelNotification(notification.id);
        }
      } else {
        // If task is not in tasksToSchedule, cancel the notification
        await notificationService.cancelNotification(notification.id);
      }
    }

    for (final task in tasksToSchedule) {
      final scheduledDate = task.dueDate!.toLocal().subtract(
            Duration(minutes: task.reminderOffsetMinutes!),
          );

      // If scheduled date is in the future, schedule the notification
      if (scheduledDate.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(
          ref: ref,
          notificationType: 'task',
          elementId: task.id,
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
