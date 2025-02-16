import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/notifications/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// For all tasks assigned to this user
// If there is a reminder offset, schedule a notification
final taskScheduleNotificationsServiceProvider = Provider((ref) {
  List<TaskModel>? previousScheduledTasks;
  // Add this flag to track if we've already set up the listener
  bool isListenerInitialized = false;

  // Only set up the listener once
  if (!isListenerInitialized) {
    isListenerInitialized = true;

    CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) => ref
          .read(tasksRepositoryProvider)
          .watchUserAssignedTasks(userId: userId),
    ).distinct().listen((currentTasks) async {
      log('Previous tasks: ${previousScheduledTasks?.map((task) => task.id).join(', ')}');
      log('Current tasks: ${currentTasks.map((task) => task.id).join(', ')}');

      final notificationService = ref.read(notificationServiceProvider);

      final tasksToSchedule = currentTasks
          .where((task) =>
              task.reminderOffsetMinutes != null &&
              task.dueDate!
                  .subtract(Duration(minutes: task.reminderOffsetMinutes!))
                  .isAfter(DateTime.now()))
          .toList();

      log('Tasks to schedule: ${tasksToSchedule.map((task) => task.id).join(', ')}');

      if (tasksToSchedule.isEmpty) {
        // Cancel all existing task notifications
        await notificationService.cancelAllNotificationsOfType(
          ref: ref,
          notificationType: 'task',
        );
        previousScheduledTasks = null;
        return;
      }

      if (previousScheduledTasks != null) {
        bool allTaskSchedulesMatch = true;

        for (final incomingTask in tasksToSchedule) {
          // Check if the task is already scheduled
          final scheduledTask = previousScheduledTasks
              ?.firstWhere((t) => t.id == incomingTask.id);

          if (scheduledTask == null) {
            allTaskSchedulesMatch = false;
            break;
          }

          // Check if the scheduled date matches the incoming date
          final scheduledDate = scheduledTask.dueDate?.subtract(
              Duration(minutes: scheduledTask.reminderOffsetMinutes!));
          final incomingDate = incomingTask.dueDate?.subtract(
              Duration(minutes: incomingTask.reminderOffsetMinutes!));

          if (scheduledDate != incomingDate) {
            allTaskSchedulesMatch = false;
            break;
          }
        }

        // If all task schedules match, no need to reschedule
        if (allTaskSchedulesMatch) {
          return;
        }
      }

      // If none of the conditions above are met, we need to update the scheduled tasks

      // Cancel all existing task notifications
      await notificationService.cancelAllNotificationsOfType(
        ref: ref,
        notificationType: 'task',
      );

      // Get localizations from the current context when needed
      final context =
          ref.read(navigationServiceProvider).navigatorKey.currentContext;
      if (context == null) return;
      final localizations = AppLocalizations.of(context)!;

      for (final task in tasksToSchedule) {
        final scheduledDate = task.dueDate!.toLocal().subtract(
              Duration(minutes: task.reminderOffsetMinutes!),
            );

        // If scheduled date is in the future, schedule the notification
        if (scheduledDate.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            ref: ref,
            notificationType: 'task',
            title: localizations.taskReminder,
            body: localizations.taskReminderBody(
              task.name,
              task.reminderOffsetMinutes!,
            ),
            scheduledDate: scheduledDate,
          );
        }
      }

      // Update previous tasks for next emission
      previousScheduledTasks = tasksToSchedule;
    });
  }

  // Return something meaningful from the provider
  return null;
});
