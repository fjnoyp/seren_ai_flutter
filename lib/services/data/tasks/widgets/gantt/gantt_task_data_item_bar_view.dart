import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/gantt_task_visual_state_provider.dart';

enum GanttCellDurationType { days, hours }

class GanttTaskDataItemBarView extends ConsumerWidget {
  final String taskId;
  final double cellWidth;
  final double cellHeight;
  final int columnStart;
  final GanttCellDurationType cellDurationType;

  const GanttTaskDataItemBarView({
    super.key,
    required this.taskId,
    required this.cellWidth,
    required this.cellHeight,
    required this.columnStart,
    required this.cellDurationType,
  });

  double _calculateEventPosition(DateTime date) {
    final startDate = DateTime.now().add(
      Duration(
        days: cellDurationType == GanttCellDurationType.days ? columnStart : 0,
        hours: cellDurationType == GanttCellDurationType.days ? 0 : columnStart,
      ),
    );

    final differenceFromStart = date.difference(startDate);
    return cellWidth *
        (cellDurationType == GanttCellDurationType.days
            ? differenceFromStart.inDays
            : differenceFromStart.inHours);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch task data and visual state
    final taskAsync = ref.watch(taskByIdStreamProvider(taskId));
    final visualState = ref.watch(ganttTaskVisualStateProvider(taskId));
    final isVisible = ref.watch(ganttTaskVisibilityProvider(taskId));

    return taskAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (task) {
        if (task == null || !isVisible) return const SizedBox.shrink();

        final hasStartDate = task.startDateTime != null;
        final hasEndDate = task.dueDate != null;
        final hasDuration = task.duration != null;

        Widget taskWidget;
        double leftPosition = 0;

        if (hasDuration) {
          leftPosition = _calculateEventPosition(task.startDateTime!);
          taskWidget = _CompleteTaskBar(
            task: task,
            color: visualState.effectiveColor,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            cellDurationType: cellDurationType,
          );
        } else if (hasStartDate || hasEndDate) {
          final date = hasStartDate ? task.startDateTime! : task.dueDate!;
          leftPosition = _calculateEventPosition(date);
          final isStart = hasStartDate;

          taskWidget = _TaskContainer(
            width: cellWidth,
            color: visualState.effectiveColor,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            borderRadius: BorderRadius.circular(4),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isStart)
                    const Text(
                      "?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Icon(
                    isStart ? Icons.arrow_forward : Icons.arrow_back,
                    color: Colors.white,
                    size: 16,
                  ),
                  if (isStart)
                    const Text(
                      "?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          taskWidget = _TaskContainer(
            width: cellWidth,
            color: Colors.red,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            child: const Center(
              child: Text(
                'Error: No dates',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Positioned(
          left: leftPosition,
          top: 5,
          child: taskWidget,
        );
      },
    );
  }
}

class _CompleteTaskBar extends ConsumerWidget {
  final TaskModel task;
  final Color color;
  final double cellWidth;
  final double cellHeight;
  final GanttCellDurationType cellDurationType;

  const _CompleteTaskBar({
    required this.task,
    required this.color,
    required this.cellWidth,
    required this.cellHeight,
    required this.cellDurationType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualState = ref.watch(ganttTaskVisualStateProvider(task.id));

    return GestureDetector(
      onTap: visualState.canExpand
          ? () => ref
              .read(ganttTaskVisualStateProvider(task.id).notifier)
              .toggleExpanded()
          : null,
      child: _TaskContainer(
        width: task.duration != null
            ? (cellDurationType == GanttCellDurationType.days
                    ? task.duration!.inDays
                    : task.duration!.inHours) *
                cellWidth
            : cellWidth,
        color: color,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            if (visualState.canExpand)
              IconButton(
                icon: Icon(
                  visualState.isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.white,
                ),
                onPressed: () => ref
                    .read(ganttTaskVisualStateProvider(task.id).notifier)
                    .toggleExpanded(),
              ),
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final BorderRadius? borderRadius;
  final double? width;
  final double cellWidth;
  final double cellHeight;

  const _TaskContainer({
    required this.child,
    required this.color,
    required this.cellWidth,
    required this.cellHeight,
    this.borderRadius,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? cellWidth * 0.3,
      height: cellHeight - 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        shape: BoxShape.rectangle,
      ),
      child: child,
    );
  }
}
