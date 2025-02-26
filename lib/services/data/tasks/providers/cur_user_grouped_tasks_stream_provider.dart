import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/date_grouped_items.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_tasks_stream_provider.dart';

List<DateGroupedItems> _groupTasksByDueDate(List<TaskModel> tasks) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Group tasks into overdue, today, and future
  final overdueTasks = <TaskModel>[];
  final todayTasks = <TaskModel>[];
  final futureTasks = <DateTime, List<TaskModel>>{};

  for (final task in tasks) {
    if (task.dueDate == null) continue;

    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    if (dueDate.isBefore(today) &&
        (task.status == StatusEnum.open ||
            task.status == StatusEnum.inProgress)) {
      overdueTasks.add(task);
    } else if (dueDate.isAtSameMomentAs(today)) {
      todayTasks.add(task);
    } else {
      if (!futureTasks.containsKey(dueDate)) {
        futureTasks[dueDate] = [];
      }
      futureTasks[dueDate]!.add(task);
    }
  }

  final groupedItems = <DateGroupedItems>[];

  // Add overdue tasks if any
  if (overdueTasks.isNotEmpty) {
    groupedItems.add(DateGroupedItems(
      today.subtract(
          const Duration(days: 1)), // Use yesterday's date for overdue
      overdueTasks,
    ));
  }

  // Add today's tasks if any
  if (todayTasks.isNotEmpty) {
    groupedItems.add(DateGroupedItems(today, todayTasks));
  }

  // Add future tasks grouped by date
  groupedItems.addAll(
    futureTasks.entries
        .map((entry) => DateGroupedItems(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)),
  );

  return groupedItems;
}

/// Stream provider that watches tasks assigned to the current user and groups them by due date
final curUserGroupedTasksStreamProvider =
    StreamProvider.autoDispose<List<DateGroupedItems>>((ref) {
  final tasksAsync = ref.watch(curUserTasksStreamProvider);

  return tasksAsync.when(
    data: (tasks) => Stream.value(_groupTasksByDueDate(tasks)),
    error: (error, stack) => Stream.error(error, stack),
    loading: () => Stream.value([]),
  );
});
