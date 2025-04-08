import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/utils/double_extension.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budget_items_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

class BudgetToCsvConverter {
  final Ref ref;

  BudgetToCsvConverter(this.ref);

  Future<String> convertBudgetToCsv({
    required String projectId,
    required List<({String rowNumber, String taskId})> numberedTasks,
    required List<BudgetItemFieldEnum> columns,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final context =
        ref.read(navigationServiceProvider).navigatorKey.currentContext;
    if (context == null) {
      throw Exception('Context not found');
    }

    final csvRows = <String>[];

    // Create CSV header
    csvRows
        .add(columns.map((field) => field.toHumanReadable(context)).join(','));

    // Add task blocks
    for (final task in numberedTasks) {
      final budgetItems = await ref
          .read(taskBudgetItemsRepositoryProvider)
          .getTaskBudgets(taskId: task.taskId);

      final taskTotalValue =
          budgetItems.fold(0.0, (sum, item) => sum + item.totalValue);

      // Add task row
      csvRows.add(await _createTaskCsvRow(
        taskId: task.taskId,
        taskNumber: task.rowNumber,
        columns: columns,
        taskTotalValue: taskTotalValue,
        projectTotalValue: projectTotalValue,
        projectBdi: projectBdi,
        currencyFormat: currencyFormat,
      ));

      // Add budget items for this task
      for (final item in budgetItems) {
        csvRows.add(await _createBudgetItemCsvRow(
          item: item,
          columns: columns,
          itemNumberPrefix: task.rowNumber,
          projectTotalValue: projectTotalValue,
          projectBdi: projectBdi,
          currencyFormat: currencyFormat,
        ));
      }
    }

    return csvRows.join('\n');
  }

  Future<String> _createTaskCsvRow({
    required String taskId,
    required String taskNumber,
    required List<BudgetItemFieldEnum> columns,
    required double taskTotalValue,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final values = await Future.wait(
      columns.map((field) async {
        final value = await _getTaskFieldValue(
          taskId: taskId,
          taskNumber: taskNumber,
          field: field,
          taskTotalValue: taskTotalValue,
          projectTotalValue: projectTotalValue,
          projectBdi: projectBdi,
          currencyFormat: currencyFormat,
        );
        return _escapeCSVValue(value);
      }),
    );

    return values.join(',');
  }

  Future<String> _createBudgetItemCsvRow({
    required TaskBudgetItemModel item,
    required List<BudgetItemFieldEnum> columns,
    required String itemNumberPrefix,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final values = await Future.wait(
      columns.map((field) async {
        final value = await _getBudgetItemFieldValue(
          item: item,
          field: field,
          itemNumberPrefix: itemNumberPrefix,
          projectTotalValue: projectTotalValue,
          projectBdi: projectBdi,
          currencyFormat: currencyFormat,
        );
        return _escapeCSVValue(value);
      }),
    );

    return values.join(',');
  }

  Future<String> _getTaskFieldValue({
    required String taskId,
    required String taskNumber,
    required BudgetItemFieldEnum field,
    required double taskTotalValue,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final taskName =
        (await ref.read(tasksRepositoryProvider).getById(taskId))?.name ??
            // Should not happen, but just in case
            'task not found';

    return switch (field) {
      BudgetItemFieldEnum.itemNumber => taskNumber.toString(),
      BudgetItemFieldEnum.name => taskName,
      BudgetItemFieldEnum.totalValue => currencyFormat.format(taskTotalValue),
      BudgetItemFieldEnum.totalValueWithBdi =>
        currencyFormat.format(taskTotalValue * (1 + projectBdi)),
      BudgetItemFieldEnum.weight =>
        (taskTotalValue / projectTotalValue).toStringAsPercentage(),
      _ => '',
    };
  }

  Future<String> _getBudgetItemFieldValue({
    required TaskBudgetItemModel item,
    required BudgetItemFieldEnum field,
    required String itemNumberPrefix,
    required double projectTotalValue,
    required double projectBdi,
    required NumberFormat currencyFormat,
  }) async {
    final matchedItemRef = item.budgetItemRefId != null
        ? await ref
                .read(budgetItemRefsRepositoryProvider)
                .getById(item.budgetItemRefId!) ??
            // Should not happen, but just in case
            BudgetItemRefModel.empty()
        : BudgetItemRefModel.empty();

    return switch (field) {
      BudgetItemFieldEnum.itemNumber => '$itemNumberPrefix.${item.itemNumber}',
      BudgetItemFieldEnum.type => matchedItemRef.type,
      BudgetItemFieldEnum.source => matchedItemRef.source,
      BudgetItemFieldEnum.code => matchedItemRef.code,
      BudgetItemFieldEnum.name => matchedItemRef.name,
      BudgetItemFieldEnum.amount => item.amount.toString(),
      BudgetItemFieldEnum.measureUnit => matchedItemRef.measureUnit,
      BudgetItemFieldEnum.unitValue => currencyFormat.format(item.unitValue),
      BudgetItemFieldEnum.unitValueWithBdi =>
        currencyFormat.format(item.unitValue * (1 + projectBdi)),
      BudgetItemFieldEnum.totalValue => currencyFormat.format(item.totalValue),
      BudgetItemFieldEnum.totalValueWithBdi =>
        currencyFormat.format(item.totalValue * (1 + projectBdi)),
      BudgetItemFieldEnum.weight =>
        (item.totalValue / projectTotalValue).toStringAsPercentage(),
    };
  }

  String _escapeCSVValue(String value) {
    // If the value contains a comma, quote, or newline, wrap it in quotes
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      // Double up any quotes
      value = value.replaceAll('"', '""');
      // Wrap in quotes
      return '"$value"';
    }
    return value;
  }
}
