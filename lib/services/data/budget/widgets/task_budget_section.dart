import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/currency_provider.dart';
import 'package:seren_ai_flutter/common/utils/double_extension.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/cur_org_available_budget_items_stream_providers.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_total_value_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/task_budget_fields.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_bdi_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';

class TaskBudgetSection extends ConsumerWidget {
  const TaskBudgetSection(this.taskId, {super.key});

  final String taskId;

  static const columns = [
    (
      field: BudgetItemFieldEnum.itemNumber,
      width: 30.0,
    ),
    (
      field: BudgetItemFieldEnum.type,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.code,
      width: 70.0,
    ),
    (
      field: BudgetItemFieldEnum.name,
      width: 200.0,
    ),
    (
      field: BudgetItemFieldEnum.measureUnit,
      width: 50.0,
    ),
    (
      field: BudgetItemFieldEnum.amount,
      width: 40.0,
    ),
    (
      field: BudgetItemFieldEnum.unitValue,
      width: 80.0,
    ),
    (
      field: BudgetItemFieldEnum.totalValue,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.unitValueWithBdi,
      width: 80.0,
    ),
    (
      field: BudgetItemFieldEnum.totalValueWithBdi,
      width: 100.0,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWidth = 1.0 +
        columns.fold(0.0, (sum, column) => sum + column.width) +
        columns.length;

    final projectBdi = ref.watch(projectBdiProvider);
    final taskBudgetItemsTotalValue =
        ref.watch(taskBudgetItemsTotalValueStreamProvider(taskId)).value ?? 0.0;

    // Single scroll controller for all horizontal lists
    final horizontalScrollController = ScrollController();

    return Column(
      children: [
        Text(
          'Total: ${ref.watch(currencyFormatSNP).format(taskBudgetItemsTotalValue * (1 + projectBdi))}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Flexible(
          child: Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: horizontalScrollController,
              child: SizedBox(
                width: totalWidth, // to properly show the dividers
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1.0),
                    const TaskBudgetHeaders(columns: columns),
                    const Divider(height: 1.0),
                    Flexible(
                      child: SingleChildScrollView(
                        child: TaskBudgetRows(
                          taskId: taskId,
                          columns: columns,
                          totalValue: taskBudgetItemsTotalValue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            ref
                .read(taskBudgetItemsServiceProvider)
                .addTaskBudgetItem(taskId: taskId);
          },
        ),
      ],
    );
  }
}

class TaskBudgetHeaders extends StatelessWidget {
  const TaskBudgetHeaders({super.key, required this.columns});

  final List<({BudgetItemFieldEnum field, double width})> columns;

  @override
  Widget build(BuildContext context) {
    final totalWidth = 1.0 +
        columns.fold(0.0, (sum, column) => sum + column.width) +
        columns.length;
    return SizedBox(
      height: 50.0,
      width: totalWidth,
      child: Row(
        children: [
          const VerticalDivider(width: 1.0),
          ...columns.expand(
            (field) => [
              SizedBox(
                width: field.width,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(field.field.toHumanReadable(context)),
                ),
              ),
              const VerticalDivider(width: 1.0),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskBudgetRows extends ConsumerWidget {
  const TaskBudgetRows({
    super.key,
    required this.taskId,
    this.taskNumber,
    required this.columns,
    required this.totalValue,
  });

  final String taskId;

  // If null, the number prefix will not be shown
  final String? taskNumber;

  final List<({BudgetItemFieldEnum field, double width})> columns;

  final double totalValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskBudgetItems =
        ref.watch(taskBudgetItemsStreamProvider(taskId)).value ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...taskBudgetItems.expand(
          (item) => [
            SizedBox(
              height: 50.0,
              child: Row(
                children: [
                  const VerticalDivider(width: 1.0),
                  ...columns.expand(
                    (column) => [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: SizedBox(
                          width: column.width - 4, // subtract the padding
                          child: _TaskBudgetItemRowValue(
                            curItem: item,
                            itemNumberPrefix:
                                taskNumber != null ? '$taskNumber.' : null,
                            field: column.field,
                            totalValue: totalValue,
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1.0),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0),
          ],
        ),
      ],
    );
  }
}

class TaskTotalBudgetRow extends ConsumerWidget {
  const TaskTotalBudgetRow({
    super.key,
    required this.taskId,
    required this.taskNumber,
    required this.columns,
    required this.projectTotalValue,
  });

  final String taskId;
  final String taskNumber;
  final double projectTotalValue;

  final List<({BudgetItemFieldEnum field, double width})> columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWidth = 1.0 +
        columns.fold(0.0, (sum, column) => sum + column.width) +
        columns.length;

    final taskName = ref.watch(taskByIdStreamProvider(taskId)
        .select((value) => value.value?.name ?? '...'));
    final projectBdi = ref.watch(projectBdiProvider);
    final numberFormat = ref.watch(currencyFormatSNP);
    final taskTotalValue =
        ref.watch(taskBudgetItemsTotalValueStreamProvider(taskId)).value ?? 0.0;

    return SizedBox(
      height: 50.0,
      width: totalWidth,
      child: Row(
        children: [
          const VerticalDivider(width: 1.0),
          ...columns.expand(
            (column) => [
              Padding(
                padding: const EdgeInsets.all(2),
                child: SizedBox(
                  width: column.width - 4, // subtract the padding
                  child: Text(
                    switch (column.field) {
                      BudgetItemFieldEnum.itemNumber => taskNumber.toString(),
                      BudgetItemFieldEnum.name => taskName,
                      BudgetItemFieldEnum.totalValue =>
                        numberFormat.format(taskTotalValue),
                      BudgetItemFieldEnum.totalValueWithBdi =>
                        numberFormat.format(taskTotalValue * (1 + projectBdi)),
                      BudgetItemFieldEnum.weight => projectTotalValue == 0
                          ? '...'
                          : (taskTotalValue / projectTotalValue)
                              .toStringAsPercentage(),
                      _ => '',
                    },
                    textAlign: [
                      BudgetItemFieldEnum.totalValue,
                      BudgetItemFieldEnum.totalValueWithBdi,
                      BudgetItemFieldEnum.weight,
                    ].contains(column.field)
                        ? TextAlign.end
                        : null,
                  ),
                ),
              ),
              [
                BudgetItemFieldEnum.itemNumber,
                BudgetItemFieldEnum.name,
                BudgetItemFieldEnum.totalValue,
                BudgetItemFieldEnum.totalValueWithBdi,
                BudgetItemFieldEnum.weight,
              ].contains(column.field)
                  ? const VerticalDivider(width: 1.0)
                  : const SizedBox(width: 1.0), // simulate a merged cell
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskBudgetItemRowValue extends ConsumerWidget {
  const _TaskBudgetItemRowValue({
    required this.curItem,
    required this.field,
    this.itemNumberPrefix,
    required this.totalValue,
  });

  final TaskBudgetItemModel curItem;
  final BudgetItemFieldEnum field;
  final String? itemNumberPrefix;
  final double totalValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectBdi = ref.watch(projectBdiProvider);
    final matchedItemRef = ref
        .watch(budgetItemRefByIdStreamProvider(curItem.budgetItemRefId))
        .value;

    final numberFormat = ref.watch(currencyFormatSNP);

    return switch (field) {
      BudgetItemFieldEnum.itemNumber => TaskBudgetItemNumberField(
          budgetItemId: curItem.id,
          isEnabled: true,
          prefix: itemNumberPrefix,
        ),
      BudgetItemFieldEnum.type => matchedItemRef == null
          ? const Text('...')
          : matchedItemRef.isOwnSource
              ? TaskBudgetTypeField(
                  budgetItemRefId: curItem.budgetItemRefId,
                  isEnabled: true,
                )
              : Text(matchedItemRef.type),
      BudgetItemFieldEnum.source => Text(matchedItemRef?.source ?? '...'),
      BudgetItemFieldEnum.code => TaskBudgetCodeField(
          budgetItemId: curItem.id,
          budgetItemRefId: curItem.budgetItemRefId,
          isEnabled: true,
        ),
      BudgetItemFieldEnum.name => TaskBudgetNameField(
          budgetItemId: curItem.id,
          budgetItemRefId: curItem.budgetItemRefId,
          isEnabled: true,
        ),
      BudgetItemFieldEnum.amount => TaskBudgetAmountField(
          budgetItemId: curItem.id,
          isEnabled: true,
        ),
      BudgetItemFieldEnum.measureUnit => matchedItemRef == null
          ? const Text('...')
          : matchedItemRef.isOwnSource
              ? TaskBudgetMeasureUnitField(
                  budgetItemRefId: curItem.budgetItemRefId,
                  isEnabled: true,
                )
              : Text(matchedItemRef.measureUnit),
      BudgetItemFieldEnum.unitValue => TaskBudgetUnitValueField(
          budgetItemId: curItem.id,
          isEnabled: true,
        ),
      BudgetItemFieldEnum.unitValueWithBdi => Text(
          numberFormat.format(curItem.unitValue * (1 + projectBdi)),
        ),
      BudgetItemFieldEnum.totalValue => Align(
          alignment: Alignment.centerRight,
          child: Text(numberFormat.format(curItem.totalValue)),
        ),
      BudgetItemFieldEnum.totalValueWithBdi => Align(
          alignment: Alignment.centerRight,
          child:
              Text(numberFormat.format(curItem.totalValue * (1 + projectBdi))),
        ),
      BudgetItemFieldEnum.weight => Align(
          alignment: Alignment.centerRight,
          child: Text(
            totalValue == 0
                ? '...'
                : (curItem.totalValue / totalValue).toStringAsPercentage(),
          ),
        ),
    };
  }
}
