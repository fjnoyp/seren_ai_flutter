import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/currency_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/cur_org_available_budget_items.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/task_budget_fields.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_bdi_provider.dart';

const _columns = [
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

final totalWidth = 1.0 +
    _columns.fold(0.0, (sum, column) => sum + column.width) +
    _columns.length;

class TaskBudgetSection extends ConsumerWidget {
  const TaskBudgetSection(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectBdi = ref.watch(projectBdiProvider);
    final taskBudgetItems =
        ref.watch(taskBudgetItemsStreamProvider(taskId)).value ?? [];

    // Single scroll controller for all horizontal lists
    final horizontalScrollController = ScrollController();

    return Column(
      children: [
        Text(
          'Total: ${ref.watch(currencyFormatSNP).format(taskBudgetItems.fold(0.0, (sum, item) => sum + item.totalValue) * (1 + projectBdi))}',
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
                    const _TaskBudgetHeaders(),
                    const Divider(height: 1.0),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _TaskBudgetRows(
                          taskBudgetItems: taskBudgetItems,
                          taskId: taskId,
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
            ref.read(taskBudgetItemsServiceProvider).addTaskBudgetItem(
                  taskId: taskId,
                  itemNumber: taskBudgetItems.length + 1,
                );
          },
        ),
      ],
    );
  }
}

class _TaskBudgetHeaders extends StatelessWidget {
  const _TaskBudgetHeaders();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Row(
        children: [
          const VerticalDivider(width: 1.0),
          ..._columns.expand(
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

class _TaskBudgetRows extends ConsumerWidget {
  const _TaskBudgetRows({required this.taskBudgetItems, required this.taskId});

  final List<TaskBudgetItemModel> taskBudgetItems;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  ..._columns.expand(
                    (column) => [
                      SizedBox(
                        width: column.width,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: _TaskBudgetRowValue(
                            curItem: item,
                            field: column.field,
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

// TODO p2: externalize this component and move it to a separate file - will be reused in other places
class _TaskBudgetRowValue extends ConsumerWidget {
  const _TaskBudgetRowValue({
    required this.curItem,
    required this.field,
  });

  final TaskBudgetItemModel curItem;
  final BudgetItemFieldEnum field;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectBdi = ref.watch(projectBdiProvider);
    final matchedItemRef = ref
            .watch(budgetItemRefByIdStreamProvider(curItem.budgetItemRefId))
            .value ??
        BudgetItemRefModel.loading();

    final numberFormat = ref.watch(currencyFormatSNP);

    return switch (field) {
      BudgetItemFieldEnum.itemNumber => TaskBudgetItemNumberField(
          budgetItemId: curItem.id,
          isEnabled: true,
        ),
      BudgetItemFieldEnum.type => matchedItemRef.isOwnSource
          ? TaskBudgetTypeField(
              budgetItemRefId: curItem.budgetItemRefId,
              isEnabled: true,
            )
          : Text(matchedItemRef.type),
      BudgetItemFieldEnum.source => Text(matchedItemRef.source),
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
      BudgetItemFieldEnum.measureUnit => matchedItemRef.isOwnSource
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
      BudgetItemFieldEnum.totalValue =>
        Text(numberFormat.format(curItem.totalValue)),
      BudgetItemFieldEnum.totalValueWithBdi => Text(
          numberFormat.format(curItem.totalValue * (1 + projectBdi)),
        ),
    };
  }
}
