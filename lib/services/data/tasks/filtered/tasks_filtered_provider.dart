import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

final tasksFilteredProvider = StreamProvider.family
    .autoDispose<List<TaskModel>, TaskFilterViewType>((ref, viewType) async* {
  final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];
  final filterState = ref.watch(taskFilterStateProvider(viewType));

  final asyncResults = await Future.wait(tasks.map((task) async {
    final matches = await filterState.asyncFilterCondition(task);
    return matches ? task : null;
  }));

  final asyncFilteredTasks = asyncResults.whereType<TaskModel>().toList();

  if (filterState.sortComparator != null) {
    asyncFilteredTasks.sort(filterState.sortComparator!);
  }

  final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);
  if (curInlineCreatingTaskId != null) {
    asyncFilteredTasks
        .add(tasks.firstWhere((t) => t.id == curInlineCreatingTaskId));
  }

  yield asyncFilteredTasks;
});

// This is currently used for Gantt chart,
// where we need to always show the ancestors of the filtered tasks
final tasksAndParentsByProjectFilteredProvider = StreamProvider.autoDispose
    .family<List<TaskModel>, String>((ref, projectId) async* {
  final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];
  final filteredTasks = ref
          .watch(tasksFilteredProvider(TaskFilterViewType.projectOverview))
          .value ??
      [];

  // First yield synchronously filtered results with ancestors
  final Set<String> tasksToInclude = {};

  // Add filtered tasks' ancestors
  for (final task in filteredTasks) {
    // Add all ancestors
    var currentTask = task;
    while (currentTask.parentTaskId != null) {
      final parent = tasks.firstWhere((t) => t.id == currentTask.parentTaskId);
      tasksToInclude.add(parent.id);
      currentTask = parent;
    }
  }

  filteredTasks.addAll(tasks.where((t) => tasksToInclude.contains(t.id)));

  yield filteredTasks;
});
