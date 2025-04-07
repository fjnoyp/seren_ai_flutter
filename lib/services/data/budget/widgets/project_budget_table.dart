import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_total_value_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/task_budget_section.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';

/// This view will be used in project periodic admeasurement tables
class ProjectBudgetTable extends ConsumerWidget {
  const ProjectBudgetTable({super.key, required this.projectId});

  final String projectId;

  static const columns = [
    (
      field: BudgetItemFieldEnum.itemNumber,
      width: 60.0,
    ),
    (
      field: BudgetItemFieldEnum.type,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.code,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.source,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.name,
      width: 400.0,
    ),
    (
      field: BudgetItemFieldEnum.measureUnit,
      width: 60.0,
    ),
    (
      field: BudgetItemFieldEnum.amount,
      width: 60.0,
    ),
    (
      field: BudgetItemFieldEnum.unitValue,
      width: 80.0,
    ),
    (
      field: BudgetItemFieldEnum.totalValue,
      width: 120.0,
    ),
    (
      field: BudgetItemFieldEnum.totalValueWithBdi,
      width: 120.0,
    ),
    (
      field: BudgetItemFieldEnum.weight,
      width: 80.0,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWidth = 1.0 +
        columns.fold(0.0, (sum, column) => sum + column.width) +
        columns.length;

    // Single scroll controller for lists and scrollbars
    final horizontalScrollController = ScrollController();
    final verticalScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // TODO p1: should be startDateTime instead
      ref
          .read(taskFilterStateProvider(TaskFilterViewType.projectBudgetTable)
              .notifier)
          .updateSortOption(TaskFieldEnum.createdAt);
      // tasks.sort((a, b) => (a.startDateTime ?? a.createdAt ?? DateTime.now())
      //     .compareTo(b.startDateTime ?? b.createdAt ?? DateTime.now()));
    });

    final numberedTasks = ref.watch(curProjectTasksHierarchyNumberedProvider);

    final projectTotalValue =
        ref.watch(projectBudgetTotalValueProvider(projectId));

    return Scrollbar(
      controller: horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        child: SizedBox(
          width: totalWidth, // to properly show the dividers
          child: Column(
            children: [
              const Divider(height: 1.0),
              const TaskBudgetHeaders(columns: columns),
              const Divider(height: 1.0),
              Flexible(
                child: Scrollbar(
                  controller: verticalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: verticalScrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...numberedTasks.map(
                          (task) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                              children: [
                                const Divider(height: 1),
                                Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withAlpha(25 *
                                          (3 -
                                              task.rowNumber
                                                  .split('.')
                                                  .length)),
                                  child: TaskTotalBudgetRow(
                                    taskId: task.taskId,
                                    taskNumber: task.rowNumber,
                                    columns: columns,
                                    projectTotalValue: projectTotalValue,
                                  ),
                                ),
                                const Divider(height: 1),
                                
                                    TaskBudgetRows(
                                      taskId: task.taskId,
                                      taskNumber: task.rowNumber,
                                      columns: columns,
                                      totalValue: projectTotalValue,
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: -12, // half of the row height
                                  left: 0,
                                  right: 0,
                                  child: SizedBox(
                                    width: totalWidth,
                                    height: 24,
                                    child: _AddItemRow(taskId: task.taskId),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddItemRow extends HookConsumerWidget {
  const _AddItemRow({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovering = useState(false);

    return MouseRegion(
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: InkWell(
        onTap: () {
          ref
              .read(taskBudgetItemsServiceProvider)
              .addTaskBudgetItem(taskId: taskId);
        },
        hoverColor: Colors.transparent,
        child: isHovering.value
            ? Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
