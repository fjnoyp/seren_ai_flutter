import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budget_items_repository.dart';

/// Returns the total value of the task budget items for a task (either a child or a phase)
final taskBudgetItemsTotalValueStreamProvider =
    StreamProvider.autoDispose.family<double, String>((ref, taskId) {
  return ref
      .read(taskBudgetItemsRepositoryProvider)
      .watchTaskBudgetTotalValue(taskId: taskId);
});

/// Returns the total value of the task budget items for a project
final projectBudgetTotalValueStreamProvider =
    StreamProvider.autoDispose.family<double, String>((ref, projectId) {
  return ref
      .read(taskBudgetItemsRepositoryProvider)
      .watchProjectBudgetTotalValue(projectId: projectId);
});
