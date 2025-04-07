import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_parent_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';

/// Returns the total value of the task budget items for a task (either a child or a phase)
final taskBudgetItemsTotalValueProvider =
    Provider.autoDispose.family<double, String>((ref, taskId) {
  final task =
      ref.watch(taskByIdStreamProvider(taskId).select((value) => value.value));

  if (task?.isPhase ?? false) {
    return ref.watch(_phaseBudgetTotalValueProvider(taskId));
  } else {
    return ref.watch(_childTaskBudgetTotalValueProvider(taskId));
  }
});

/// Returns the total value of the task budget items for a project
final projectBudgetTotalValueProvider =
    Provider.autoDispose.family<double, String>((ref, projectId) {
  final tasks = ref.watch(tasksByProjectStreamProvider(projectId)).value;
  if (tasks == null) {
    return 0.0;
  }

  // get only child tasks to avoid double counting
  final childTaskIds =
      tasks.where((task) => !task.isPhase).map((task) => task.id).toList();

  return [
    ...childTaskIds
        .map((taskId) => ref.watch(_childTaskBudgetTotalValueProvider(taskId))),
  ].fold(0.0, (sum, value) => sum + value);
});

final _childTaskBudgetTotalValueProvider =
    Provider.autoDispose.family<double, String>((ref, taskId) {
  final taskBudgetItems = ref.watch(taskBudgetItemsStreamProvider(taskId));
  if (taskBudgetItems.value == null) {
    return 0.0;
  }

  return taskBudgetItems.value!.fold(0.0, (sum, item) => sum + item.totalValue);
});

final AutoDisposeProviderFamily<double, String> _phaseBudgetTotalValueProvider =
    Provider.autoDispose.family<double, String>((ref, phaseId) {
  final childTaskIds =
      ref.watch(taskIdsByParentStreamProvider(phaseId)).value ?? [];
  final tasksTotalValues = [
    ...childTaskIds
        .map((taskId) => ref.watch(taskBudgetItemsTotalValueProvider(taskId))),
  ];
  return tasksTotalValues.fold(0.0, (sum, value) => sum + value);
});
