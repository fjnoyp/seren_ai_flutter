import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_total_value_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/task_budget_section.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';

/// This view will be used in project periodic admeasurement tables
class ProjectBudgetTable extends HookConsumerWidget {
  const ProjectBudgetTable({
    super.key,
    required this.projectId,
    required this.columns,
  });

  final String projectId;
  final List<({BudgetItemFieldEnum field, double width})> columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWidth = 1.0 +
        columns.fold(0.0, (sum, column) => sum + column.width) +
        columns.length;

    // Single scroll controller for lists and scrollbars
    final horizontalScrollController = useScrollController();
    final verticalScrollController = useScrollController();

    final numberedTasks = ref.watch(curProjectTasksHierarchyNumberedProvider);

    final projectTotalValue =
        ref.watch(projectBudgetTotalValueStreamProvider(projectId)).value ??
            0.0;

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
              TaskBudgetHeaders(columns: columns),
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
