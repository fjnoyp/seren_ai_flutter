import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

final tasksFilteredProvider = StateProvider.autoDispose<List<TaskModel>>((ref) {
  final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];
  final filterState = ref.watch(taskFilterStateProvider);

  final filteredTasks =
      tasks.where((task) => filterState.filterCondition(task)).toList();

  if (filterState.sortComparator != null) {
    filteredTasks.sort(filterState.sortComparator!);
  }

  return filteredTasks;
});

final tasksByProjectsFilteredProvider = StateProvider.autoDispose
    .family<List<TaskModel>, String?>((ref, projectId) {
  final tasks = ref
          .watch(projectId == null
              ? curUserViewableTasksStreamProvider
              : tasksByProjectStreamProvider(projectId))
          .value ??
      [];

  final filterState = ref.watch(taskFilterStateProvider);

  final filteredTasks =
      tasks.where((task) => filterState.filterCondition(task)).toList();

  if (filterState.sortComparator != null) {
    filteredTasks.sort(filterState.sortComparator!);
  }

  final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

  if (curInlineCreatingTaskId != null &&
      !filteredTasks.any((t) => t.id == curInlineCreatingTaskId)) {
    filteredTasks.add(tasks.firstWhere((t) => t.id == curInlineCreatingTaskId));
  }

  return filteredTasks;
});

final tasksAndParentsByProjectFilteredProvider = StateProvider.autoDispose
    .family<List<TaskModel>, String?>((ref, projectId) {
  final tasks = ref
          .watch(projectId == null
              ? curUserViewableTasksStreamProvider
              : tasksByProjectStreamProvider(projectId))
          .value ??
      [];

  // Create a set of all task IDs we need to include (filtered tasks + their ancestors)
  final Set<String> tasksToInclude = {};

  final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

  if (curInlineCreatingTaskId != null) {
    tasksToInclude.add(curInlineCreatingTaskId);
  }

  final filterState = ref.watch(taskFilterStateProvider);

  // Add filtered tasks and their ancestors
  for (final task in tasks) {
    if (filterState.filterCondition(task)) {
      tasksToInclude.add(task.id);

      // Add all ancestors
      var currentTask = task;
      while (currentTask.parentTaskId != null) {
        final parent =
            tasks.firstWhere((t) => t.id == currentTask.parentTaskId);
        tasksToInclude.add(parent.id);
        currentTask = parent;
      }
    }
  }

  // Create a filtered list of tasks that pass the filter
  final filteredTasks =
      tasks.where((task) => tasksToInclude.contains(task.id)).toList();

  if (filterState.sortComparator != null) {
    filteredTasks.sort(filterState.sortComparator!);
  }

  return filteredTasks;
});
