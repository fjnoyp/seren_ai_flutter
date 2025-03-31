import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';

final taskBudgetsRepositoryProvider = Provider<TaskBudgetsRepository>((ref) {
  return TaskBudgetsRepository(ref.watch(dbProvider), ref);
});

class TaskBudgetsRepository extends BaseRepository<TaskBudgetItemModel> {
  final Ref ref;

  const TaskBudgetsRepository(super.db, this.ref,
      {super.primaryTable = 'task_budgets'});

  @override
  TaskBudgetItemModel fromJson(Map<String, dynamic> json) {
    return TaskBudgetItemModel.fromJson(json);
  }

  Stream<List<TaskBudgetItemModel>> watchTaskBudgets({
    required String taskId,
  }) {
    return Stream.periodic(const Duration(seconds: 5))
        .map((_) => _getMockedTaskBudgets(taskId));
    // return watch(
    //   BudgetQueries.taskBudgetsQuery,
    //   {
    //     'task_id': taskId,
    //   },
    // );
  }

  Future<List<TaskBudgetItemModel>> getTaskBudgets({
    required String taskId,
  }) async {
    return _getMockedTaskBudgets(taskId);
    // return get(
    //   BudgetQueries.taskBudgetsQuery,
    //   {
    //     'task_id': taskId,
    //   },
    // );
  }

  Stream<TaskBudgetItemModel> watchTaskBudgetItemById({
    required String budgetItemId,
  }) {
    return Stream.periodic(const Duration(seconds: 5))
        .map((_) => _getMockedTaskBudgets('123').firstWhere(
              (e) => e.budgetItemRefId == budgetItemId,
              orElse: () => TaskBudgetItemModel.empty(),
            ));
    // return watchSingle(
    //   BudgetQueries.getBudgetItemQuery,
    //   {
    //     'item_id': budgetItemId,
    //   },
    // );
  }

  Future<TaskBudgetItemModel> getTaskBudgetItemById({
    required String budgetItemId,
  }) async {
    return _getMockedTaskBudgets('123').firstWhere(
      (e) => e.budgetItemRefId == budgetItemId,
      orElse: () => TaskBudgetItemModel.empty(),
    );
    // return getSingle(
    //   BudgetQueries.getBudgetItemQuery,
    //   {
    //     'item_id': budgetItemId,
    //   },
    // );
  }

  Future<void> updateBudgetItemField({
    required String budgetItemId,
    required BudgetItemFieldEnum field,
    required String value,
  }) async {
    // TODO p0: Implement this
    print('updateBudgetItemField: $budgetItemId, $field, $value');
  }

  // Helper method to get mocked task budgets
  List<TaskBudgetItemModel> _getMockedTaskBudgets(String taskId) {
    return [
      TaskBudgetItemModel(
        id: '1',
        parentTaskId: taskId,
        budgetItemRefId: '19659318',
        itemNumber: 1,
        amount: 5.0,
        unitValue: 81.11,
        isEstimated: true,
      ),
      TaskBudgetItemModel(
        id: '2',
        parentTaskId: taskId,
        budgetItemRefId: '19662001',
        itemNumber: 2,
        amount: 10.0,
        unitValue: 43.58,
        isEstimated: false,
      ),
      TaskBudgetItemModel(
        id: '3',
        parentTaskId: taskId,
        budgetItemRefId: '19659956',
        itemNumber: 3,
        amount: 25.5,
        unitValue: 197.31,
        isEstimated: true,
      ),
      TaskBudgetItemModel(
        id: '4',
        parentTaskId: taskId,
        budgetItemRefId: '19666842',
        itemNumber: 4,
        amount: 100.0,
        unitValue: 11.13,
        isEstimated: false,
      ),
      TaskBudgetItemModel(
        id: '5',
        parentTaskId: taskId,
        budgetItemRefId: '19666843',
        itemNumber: 5,
        amount: 75.0,
        unitValue: 11.17,
        isEstimated: true,
      ),
      TaskBudgetItemModel(
        id: '6',
        parentTaskId: taskId,
        budgetItemRefId: '19666844',
        itemNumber: 6,
        amount: 50.0,
        unitValue: 12.23,
        isEstimated: false,
      ),
      TaskBudgetItemModel(
        id: '7',
        parentTaskId: taskId,
        budgetItemRefId: '19666845',
        itemNumber: 7,
        amount: 30.0,
        unitValue: 8.99,
        isEstimated: true,
      ),
      TaskBudgetItemModel(
        id: '8',
        parentTaskId: taskId,
        budgetItemRefId: '19659957',
        itemNumber: 8,
        amount: 15.0,
        unitValue: 340.19,
        isEstimated: false,
      ),
      TaskBudgetItemModel(
        id: '9',
        parentTaskId: taskId,
        budgetItemRefId: '19669779',
        itemNumber: 9,
        amount: 2.0,
        unitValue: 1419.75,
        isEstimated: true,
      ),
      TaskBudgetItemModel(
        id: '10',
        parentTaskId: taskId,
        budgetItemRefId: '19671186',
        itemNumber: 10,
        amount: 200.0,
        unitValue: 0.77,
        isEstimated: false,
      ),
    ];
  }
}
