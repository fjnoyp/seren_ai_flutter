import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budgets_repository.dart';

final taskBudgetItemsStreamProvider = StreamProvider.autoDispose
    .family<List<TaskBudgetItemModel>?, String>((ref, taskId) {
  return ref
      .read(taskBudgetsRepositoryProvider)
      .watchTaskBudgets(taskId: taskId);
});

final taskBudgetItemByIdProvider =
    StreamProvider.family<TaskBudgetItemModel, String>((ref, budgetItemId) {
  return ref.read(taskBudgetsRepositoryProvider).watchTaskBudgetItemById(
        budgetItemId: budgetItemId,
      );
});
