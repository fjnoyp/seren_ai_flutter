import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/gantt_task_visual_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/viewable_tasks_hierarchy_provider.dart';

class GanttTaskDataItemBarView extends ConsumerWidget {
  final String taskId;
  final double cellWidth;
  final double cellHeight;
  final int columnStartDay;

  const GanttTaskDataItemBarView({
    super.key,
    required this.taskId,
    required this.cellWidth,
    required this.cellHeight,
    required this.columnStartDay,
  });

  double _calculateEventPosition(DateTime date) {
    final startDate = DateTime.now().add(Duration(days: columnStartDay));
    return date.difference(startDate).inDays * cellWidth;
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

  const _CompleteTaskBar({
    required this.task,
    required this.color,
    required this.cellWidth,
    required this.cellHeight,
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
            ? task.duration!.inDays * cellWidth
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
  final BoxShape shape;
  final double? width;
  final double cellWidth;
  final double cellHeight;

  const _TaskContainer({
    super.key,
    required this.child,
    required this.color,
    required this.cellWidth,
    required this.cellHeight,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
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
        shape: shape,
      ),
      child: child,
    );
  }
}
