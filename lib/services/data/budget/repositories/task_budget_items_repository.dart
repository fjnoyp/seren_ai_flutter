import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_queries.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final taskBudgetItemsRepositoryProvider =
    Provider<TaskBudgetItemsRepository>((ref) {
  return TaskBudgetItemsRepository(ref.watch(dbProvider), ref);
});

class TaskBudgetItemsRepository extends BaseRepository<TaskBudgetItemModel> {
  final Ref ref;

  const TaskBudgetItemsRepository(super.db, this.ref,
      {super.primaryTable = 'task_budget_items'});

  @override
  TaskBudgetItemModel fromJson(Map<String, dynamic> json) {
    return TaskBudgetItemModel.fromJson(json);
  }

  Stream<List<TaskBudgetItemModel>> watchTaskBudgets({
    required String taskId,
  }) {
    return watch(
      BudgetQueries.getTaskBudgetsQuery,
      {
        'task_id': taskId,
      },
    );
  }

  Future<List<TaskBudgetItemModel>> getTaskBudgets({
    required String taskId,
  }) async {
    return get(
      BudgetQueries.getTaskBudgetsQuery,
      {
        'task_id': taskId,
      },
    );
  }

  Stream<double> watchTaskBudgetTotalValue({
    required String taskId,
  }) {
    return db.watch(
      BudgetQueries.getTaskBudgetTotalValueQuery,
      parameters: [taskId],
      triggerOnTables: ['task_budget_items', 'tasks'],
    ).map((results) {
      // Extract the 'total_value' from the result map
      final totalValue = results.first['total_value'];
      // Handle null case (when there are no budget items)
      return totalValue != null ? totalValue as double : 0.0;
    });
  }

  Future<double> getTaskBudgetTotalValue({
    required String taskId,
  }) async {
    return db.execute(
      BudgetQueries.getTaskBudgetTotalValueQuery,
      [taskId],
    ).then((results) {
      // Extract the 'total_value' from the result map
      final totalValue = results.first['total_value'];
      // Handle null case (when there are no budget items)
      return totalValue != null ? totalValue as double : 0.0;
    });
  }

  Stream<double> watchProjectBudgetTotalValue({
    required String projectId,
  }) {
    return db.watch(
      BudgetQueries.getProjectBudgetTotalValueQuery,
      parameters: [projectId],
      triggerOnTables: ['task_budget_items', 'tasks'],
    ).map((results) {
      // Extract the 'total_value' from the result map
      final totalValue = results.first['total_value'];
      // Handle null case (when there are no budget items)
      return totalValue != null ? totalValue as double : 0.0;
    });
  }

  Future<double> getProjectBudgetTotalValue({
    required String projectId,
  }) async {
    return db.execute(
      BudgetQueries.getProjectBudgetTotalValueQuery,
      [projectId],
    ).then((results) {
      // Extract the 'total_value' from the result map
      final totalValue = results.first['total_value'];
      // Handle null case (when there are no budget items)
      return totalValue != null ? totalValue as double : 0.0;
    });
  }

  Future<void> updateTaskBudgetItemField({
    required String budgetItemId,
    required BudgetItemFieldEnum field,
    required String value,
  }) async {
    switch (field) {
      case BudgetItemFieldEnum.itemNumber:
        // Handle item number update for the current item and all items between the current and the new item number
        await Supabase.instance.client.rpc(
          'update_task_budget_item_number',
          params: {
            'budget_item_id': budgetItemId,
            'new_item_number': value,
          },
        );
        break;
      default:
        await updateField(budgetItemId, field.toDbField(), value);
    }
  }

  /// Updates the reference of a task budget item
  Future<void> updateTaskBudgetItemReference({
    required String budgetItemId,
    required String budgetItemRefId,
  }) async {
    await updateField(budgetItemId, 'budget_item_ref_id', budgetItemRefId);

    // Get the base unit value from the budget item reference
    final baseUnitValue = await ref
        .read(budgetItemRefsRepositoryProvider)
        .getById(budgetItemRefId)
        .then((value) => value?.baseUnitValue);

    if (baseUnitValue != null && baseUnitValue != 0) {
      await updateField(
        budgetItemId,
        BudgetItemFieldEnum.unitValue.toDbField(),
        baseUnitValue,
      );
    }
  }
}
