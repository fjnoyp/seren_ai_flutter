import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/status_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/gantt_task_visual_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_assignees_avatars.dart';

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
              final visualState =
                  ref.watch(ganttTaskVisualStateProvider(taskId));
              final isVisible = ref.watch(ganttTaskVisibilityProvider(taskId));
              return visualState.canExpand
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
              child: InkWell(
                onTap: () => ref
                    .read(ganttTaskVisualStateProvider(taskId).notifier)
                    .toggleExpanded(),
                child: SizedBox(
                  height: cellHeight,
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(task.name),
                    ],
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
              child: GestureDetector(
                onTapDown: (details) => showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    details.globalPosition.dx + 1,
                    details.globalPosition.dy + 1,
                  ),
                  items: [
                    PopupMenuItem(
                      enabled: false,
                      child: _TaskDetailsPopup(task),
                    )
                  ],
                ),
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

class _TaskDetailsPopup extends StatelessWidget {
  const _TaskDetailsPopup(this.task);

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      task.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) => IconButton(
                      onPressed: () => ref
                          .read(taskNavigationServiceProvider)
                          .openTask(initialTaskId: task.id),
                      icon: const Icon(Icons.open_in_new),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
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
    switch (fieldType) {
      case TaskFieldEnum.name:
        return Text(
          task?.name ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case TaskFieldEnum.status:
        return Center(
          child: StatusView(
            status: task?.status ?? StatusEnum.open,
            outline: false,
          ),
        );
      case TaskFieldEnum.priority:
        return Center(
          child: PriorityView(
            priority: task?.priority ?? PriorityEnum.normal,
            outline: false,
          ),
        );
      case TaskFieldEnum.assignees:
        return TaskAssigneesAvatars(taskId);
    }
  }
}
