import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/gantt_task_visual_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_creation_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

class GanttStaticColumnView extends ConsumerWidget {
  static const Map<TaskFieldEnum, double> columnWidths = {
    TaskFieldEnum.name: 110.0,
    TaskFieldEnum.status: 80.0,
    TaskFieldEnum.priority: 80.0,
    TaskFieldEnum.assignees: 80.0,
  };

  final ScrollController? verticalController;
  final double cellHeight;
  final ScrollController mainVerticalController;

  const GanttStaticColumnView({
    super.key,
    required this.cellHeight,
    this.verticalController,
    required this.mainVerticalController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleTaskIds = ref.watch(curProjectTasksHierarchyIdsProvider);
    final staticColumnHeaders = [
      TaskFieldEnum.name,
      TaskFieldEnum.assignees,
      TaskFieldEnum.status,
      TaskFieldEnum.priority
    ];

    return Listener(
      onPointerSignal: _handlePointerScroll,
      child: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDrag,
        child: SizedBox(
          width: staticColumnHeaders.fold<double>(
            0,
            (sum, field) => sum + columnWidths[field]!,
          ),
          child: Column(
            children: [
              _StaticHeader(
                staticColumnHeaders: staticColumnHeaders,
              ),
              _StaticRowValues(
                taskIds: visibleTaskIds,
                cellHeight: cellHeight,
                verticalController: verticalController,
                staticColumnHeaders: staticColumnHeaders,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePointerScroll(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      mainVerticalController.position.moveTo(
        mainVerticalController.offset + pointerSignal.scrollDelta.dy,
        clamp: true,
      );
    }
  }

  void _handleVerticalDrag(DragUpdateDetails details) {
    mainVerticalController.position.moveTo(
      mainVerticalController.offset - details.delta.dy,
      clamp: true,
    );
  }
}

class _StaticHeader extends StatelessWidget {
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticHeader({required this.staticColumnHeaders});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        staticColumnHeaders.length,
        (index) => Container(
          width:
              GanttStaticColumnView.columnWidths[staticColumnHeaders[index]]!,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          child: Text(
            staticColumnHeaders[index].toHumanReadable(context),
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _StaticRowValues extends ConsumerWidget {
  final List<String> taskIds;
  final double cellHeight;
  final ScrollController? verticalController;
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticRowValues({
    required this.taskIds,
    required this.cellHeight,
    required this.verticalController,
    required this.staticColumnHeaders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curEditingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

    // RepaintBoundary should wrap the ListView, not the Expanded
    return Expanded(
      child: RepaintBoundary(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            controller: verticalController,
            itemCount: taskIds.length,
            cacheExtent: 200,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, rowIndex) {
              final taskId = taskIds[rowIndex];

              return taskId == curEditingTaskId
                  ? Stack(
                      children: [
                        Container(
                          height: cellHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withAlpha(51),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            ),
                          ),
                        ),
                        _StaticRow(
                          taskId: taskId,
                          cellHeight: cellHeight,
                          staticColumnHeaders: staticColumnHeaders,
                        ),
                      ],
                    )
                  : _StaticRow(
                      taskId: taskId,
                      cellHeight: cellHeight,
                      staticColumnHeaders: staticColumnHeaders,
                    );
            },
            separatorBuilder: (context, index) {
              final isTaskVisible =
                  ref.watch(ganttTaskVisibilityProvider(taskIds[index]));
              return isTaskVisible
                  ? const Divider(height: 1)
                  : const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _StaticRow extends ConsumerWidget {
  final String taskId;
  final double cellHeight;
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticRow({
    required this.taskId,
    required this.cellHeight,
    required this.staticColumnHeaders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdStreamProvider(taskId)).value;

    final visualState = ref.watch(ganttTaskVisualStateProvider(taskId));
    final isVisible = ref.watch(ganttTaskVisibilityProvider(taskId));
    return task != null && task.isPhase
        ? _StaticPhaseRow(
            taskId: taskId,
            cellHeight: cellHeight,
            isExpanded: visualState.isExpanded,
          )
        : isVisible
            ? _StaticTaskRow(
                taskId: taskId,
                cellHeight: cellHeight,
                staticColumnHeaders: staticColumnHeaders,
              )
            : const SizedBox.shrink();
  }
}

class _StaticPhaseRow extends ConsumerWidget {
  final String taskId;
  final double cellHeight;
  final bool isExpanded;

  const _StaticPhaseRow({
    required this.taskId,
    required this.cellHeight,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdStreamProvider(taskId));

    return task.when(
      data: (task) => task != null
          ? RepaintBoundary(
              child: SizedBox(
                height: cellHeight,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => ref
                          .read(ganttTaskVisualStateProvider(taskId).notifier)
                          .toggleExpanded(),
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child:
                          task.id == ref.watch(curInlineCreatingTaskIdProvider)
                              ? InlineTaskNameField(
                                  taskId: taskId,
                                  isPhase: true,
                                )
                              : Tooltip(
                                  preferBelow: true,
                                  richMessage: _buildTaskTooltipRichMessage(
                                    context,
                                    task,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      ref
                                          .read(taskNavigationServiceProvider)
                                          .openTask(initialTaskId: taskId);
                                    },
                                    child: Text(
                                      task.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                    ),
                    if (task.id != ref.watch(curInlineCreatingTaskIdProvider))
                      InlineTaskCreationButton(initialParentTaskId: taskId),
                  ],
                ),
              ),
            )
          : SizedBox(height: cellHeight),
      loading: () => SizedBox(
        height: cellHeight,
        child: const Center(child: LinearProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          const Center(child: Text('Error loading phase')),
    );
  }
}

// Split into separate widgets for better performance
class _StaticTaskRow extends ConsumerWidget {
  final String taskId;
  final double cellHeight;
  final List<TaskFieldEnum> staticColumnHeaders;

  const _StaticTaskRow({
    required this.taskId,
    required this.cellHeight,
    required this.staticColumnHeaders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdStreamProvider(taskId));

    return task.when(
      data: (task) => task != null
          ? RepaintBoundary(
              child: Row(
                children: List.generate(
                  staticColumnHeaders.length,
                  (columnIndex) => _StaticCell(
                    taskId: taskId,
                    cellHeight: cellHeight,
                    fieldType: staticColumnHeaders[columnIndex],
                  ),
                ),
              ),
            )
          : SizedBox(height: cellHeight),
      loading: () => SizedBox(
        height: cellHeight,
        child: const Center(child: LinearProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          const Center(child: Text('Error loading task')),
    );
  }
}

class _StaticCell extends StatelessWidget {
  final String taskId;
  final double cellHeight;
  final TaskFieldEnum fieldType;

  const _StaticCell({
    required this.taskId,
    required this.cellHeight,
    required this.fieldType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      width: GanttStaticColumnView.columnWidths[fieldType]!,
      height: cellHeight,
      alignment: Alignment.centerLeft,
      child: _StaticCellContent(
        taskId: taskId,
        fieldType: fieldType,
      ),
    );
  }
}

class _StaticCellContent extends ConsumerWidget {
  final String taskId;
  final TaskFieldEnum fieldType;

  const _StaticCellContent({
    required this.taskId,
    required this.fieldType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdStreamProvider(taskId)).value;
    if (task == null) return const SizedBox.shrink();
    switch (fieldType) {
      case TaskFieldEnum.name:
        if (task.id == ref.watch(curInlineCreatingTaskIdProvider)) {
          return InlineTaskNameField(
            taskId: taskId,
            initialParentTaskId: task.parentTaskId,
          );
        }
        // We needed to move InkWell to prevent the parent's onTap
        // from blocking the menu from being shown for status/priority fields.
        return Padding(
          padding: EdgeInsets.only(
            left: task.parentTaskId == null ? 0 : 16,
          ),
          child: Tooltip(
            preferBelow: true,
            richMessage: _buildTaskTooltipRichMessage(context, task),
            waitDuration: const Duration(milliseconds: 500),
            child: InkWell(
              onTap: () {
                ref.read(taskNavigationServiceProvider).openTask(
                      initialTaskId: task.id,
                    );
              },
              child: Text(
                task.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      case TaskFieldEnum.status:
        return TaskStatusSelectionField(
          taskId: taskId,
          showLabelWidget: false,
        );
      case TaskFieldEnum.priority:
        return TaskPrioritySelectionField(
          taskId: taskId,
          showLabelWidget: false,
        );
      case TaskFieldEnum.assignees:
        if (task.id != ref.watch(curInlineCreatingTaskIdProvider)) {
          return TaskAssigneesSelectionField(
            taskId: taskId,
            context: context,
            showLabelWidget: false,
            useIconButton: true,
          );
        }
        return const SizedBox.shrink();
      default:
        // TaskFieldEnum values that are not included in the static column view
        return const SizedBox.shrink();
    }
  }
}

WidgetSpan _buildTaskTooltipRichMessage(BuildContext context, TaskModel task) {
  final theme = Theme.of(context);
  return WidgetSpan(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.surface,
            ) ??
            const TextStyle(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (task.description != null && task.description!.isNotEmpty)
                Text('\n${task.description!}'),
            ],
          ),
        ),
      ),
    ),
  );
}
