import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budget_items_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

final taskBudgetItemsServiceProvider =
    Provider<TaskBudgetItemsService>((ref) => TaskBudgetItemsService(ref));

class TaskBudgetItemsService {
  final Ref ref;

  TaskBudgetItemsService(this.ref);

  /// Adds a new task budget item
  Future<void> addTaskBudgetItem({required String taskId}) async {
    final taskBudgetsRepository = ref.read(taskBudgetItemsRepositoryProvider);
    final taskBudgetItems =
        ref.read(taskBudgetItemsStreamProvider(taskId)).value;
    if (taskBudgetItems == null) {
      log('should not add a task budget item before the stream is initialized');
      return;
    }

    final newTaskBudgetItem = TaskBudgetItemModel(
      parentTaskId: taskId,
      itemNumber: taskBudgetItems.length + 1,
      amount: 0,
      unitValue: 0,
    );

    await taskBudgetsRepository.insertItem(newTaskBudgetItem);
  }

  /// Creates a new budget item reference and returns its ID
  Future<String> createBudgetItemRef({
    String? type,
    String? code,
    String? name,
    String? measureUnit,
    double? baseUnitValue,
  }) async {
    final budgetItemRefsRepository = ref.read(budgetItemRefsRepositoryProvider);
    final curSelectedOrgId = ref.read(curSelectedOrgIdNotifierProvider);

    final newBudgetItemRef = BudgetItemRefModel.empty().copyWith(
      parentOrgId: curSelectedOrgId,
      source: 'own',
      type: type,
      code: code,
      name: name,
      measureUnit: measureUnit,
      baseUnitValue: baseUnitValue,
    );

    await budgetItemRefsRepository.insertItem(newBudgetItemRef);

    return newBudgetItemRef.id;
  }
}
