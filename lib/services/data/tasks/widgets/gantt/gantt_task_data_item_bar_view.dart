import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/gantt_task_visual_state_provider.dart';

enum GanttCellDurationType { days, hours }

const _dragBordersHandleWidth = 20.0;

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
    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day, now.hour).add(
      Duration(
        days: cellDurationType == GanttCellDurationType.days ? columnStart : 0,
        hours: cellDurationType == GanttCellDurationType.days ? 0 : columnStart,
      ),
    );

    final differenceFromStart = date.difference(startDateTime);
    return cellWidth *
        (cellDurationType == GanttCellDurationType.days
            ? differenceFromStart.inDays
            : differenceFromStart.inHours) -
        _dragBordersHandleWidth;
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
          if (hasEndDate) leftPosition -= cellWidth; // align task at its end
          final hasStart = hasStartDate;

          taskWidget = _TaskContainer(
            width: cellWidth,
            color: visualState.effectiveColor,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            onDragFromMiddle: (cells) {
              final timeOffset = _getTimeOffset(cells, cellDurationType);
              if (hasStart) {
                ref.read(tasksRepositoryProvider).updateTaskStartDateTime(
                      task.id,
                      date.add(timeOffset),
                    );
              } else {
                ref.read(tasksRepositoryProvider).updateTaskDueDate(
                      task.id,
                      date.add(timeOffset),
                    );
              }
            },
            onDragFromStart: (cells) {
              if (hasStart) {
                ref.read(tasksRepositoryProvider).updateTaskStartDateTime(
                      task.id,
                      task.startDateTime!
                          .add(_getTimeOffset(cells, cellDurationType)),
                    );
              } else {
                if (cells <= 0) {
                  ref.read(tasksRepositoryProvider).updateTaskStartDateTime(
                        task.id,
                        task.dueDate!.add(
                            // using cells - 1 because we're dragging from the start and using dueDate as reference
                            _getTimeOffset(cells - 1, cellDurationType)),
                      );
                }
              }
            },
            onDragFromEnd: (cells) {
              if (hasStart) {
                if (cells >= 0) {
                  ref.read(tasksRepositoryProvider).updateTaskDueDate(
                        task.id,
                        task.startDateTime!.add(
                            // using cells + 1 because we're dragging from the end and using startDateTime as reference
                            _getTimeOffset(cells + 1, cellDurationType)),
                      );
                }
              } else {
                ref.read(tasksRepositoryProvider).updateTaskDueDate(
                      task.id,
                      task.dueDate!
                          .add(_getTimeOffset(cells, cellDurationType)),
                    );
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hasStart)
                      const Text(
                        "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Icon(
                      hasStart ? Icons.arrow_forward : Icons.arrow_back,
                      color: Colors.white,
                      size: 16,
                    ),
                    if (hasStart)
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
            ),
          );
        } else {
          taskWidget = _TaskContainer(
            width: cellWidth,
            color: Colors.red,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            onDragFromMiddle: (_) {},
            onDragFromStart: (_) {},
            onDragFromEnd: (_) {},
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

    int durationInCells = cellDurationType == GanttCellDurationType.days
        ? task.duration!.inDays
        : task.duration!.inHours;
    if (durationInCells == 0) durationInCells = 1;

    return _TaskContainer(
        onDragFromMiddle: (cells) {
          final offset = _getTimeOffset(cells, cellDurationType);
          ref.read(tasksRepositoryProvider).updateTaskStartDateTime(
                task.id,
                task.startDateTime!.add(offset),
              );
          ref.read(tasksRepositoryProvider).updateTaskDueDate(
                task.id,
                task.dueDate!.add(offset),
              );
        },
        onDragFromStart: (cells) {
          final timeOffset = _getTimeOffset(cells, cellDurationType);
          if (task.duration != null && timeOffset < task.duration!) {
            ref.read(tasksRepositoryProvider).updateTaskStartDateTime(
                  task.id,
                  task.startDateTime!.add(timeOffset),
                );
          }
        },
        onDragFromEnd: (cells) {
          final timeOffset = _getTimeOffset(cells, cellDurationType);
          if (task.duration != null && timeOffset > -task.duration!) {
            ref.read(tasksRepositoryProvider).updateTaskDueDate(
                  task.id,
                  task.dueDate!.add(timeOffset),
                );
          }
        },
        width: task.duration != null ? durationInCells * cellWidth : cellWidth,
        color: color,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
    );
  }
}

Duration _getTimeOffset(double cells, GanttCellDurationType cellDurationType) {
  return Duration(
    days: cellDurationType == GanttCellDurationType.days ? cells.round() : 0,
    hours: cellDurationType == GanttCellDurationType.days ? 0 : cells.round(),
  );
}

enum _DragType { startDate, endDate, all }

class _TaskContainer extends HookWidget {
  final Widget child;
  final Color color;
  final BorderRadius? borderRadius;
  final double? width;
  final double cellWidth;
  final double cellHeight;

  final void Function(double) onDragFromMiddle;
  final void Function(double) onDragFromStart;
  final void Function(double) onDragFromEnd;

  const _TaskContainer({
    required this.child,
    required this.color,
    required this.cellWidth,
    required this.cellHeight,
    this.borderRadius,
    this.width,
    required this.onDragFromMiddle,
    required this.onDragFromStart,
    required this.onDragFromEnd,
  });

  @override
  Widget build(BuildContext context) {
    Offset? startPosition;
    // Use useRef instead of useState to avoid rebuilds
    final dragType = useRef(_DragType.all);

    // Draggable's onDragEnd is not working properly due to scroll,
    // so we're using a Listener to get the position
    return Listener(
      onPointerUp: (event) {
        if (startPosition != null) {
          final delta = event.position.dx - startPosition!.dx;

          final hoursOffset = (delta / cellWidth);
          switch (dragType.value) {
            case _DragType.startDate:
              onDragFromStart(hoursOffset);
              break;
            case _DragType.endDate:
              onDragFromEnd(hoursOffset);
              break;
            case _DragType.all:
              onDragFromMiddle(hoursOffset);
          }
        }
      },
      child: Row(
        children: [
          Draggable(
            axis: Axis.horizontal,
            feedback:
                Container(color: Colors.white, width: 2, height: cellHeight),
            child: InkWell(
              onTapDown: (details) {
                startPosition = details.globalPosition;
                dragType.value = _DragType.startDate;
              },
              mouseCursor: SystemMouseCursors.resizeLeft,
              hoverColor: Colors.white,
              child: Tooltip(
                message: "Change start date",
                child: SizedBox(width: _dragBordersHandleWidth, height: cellHeight),
              ),
            ),
          ),
          Draggable(
            axis: Axis.horizontal,
            // Feedback widget shown while dragging
            feedback: Material(
              child: Container(
                width: width ?? cellWidth * 0.3,
                height: cellHeight - 10,
                decoration: BoxDecoration(
                  color: color.withAlpha(200),
                  borderRadius: borderRadius,
                  shape: BoxShape.rectangle,
                ),
                child: child,
              ),
            ),
            // Optional: Show a child widget where the drag started
            childWhenDragging: Container(
              width: width ?? cellWidth * 0.3,
              height: cellHeight - 10,
              decoration: BoxDecoration(
                color: color.withAlpha(55),
                borderRadius: borderRadius,
                shape: BoxShape.rectangle,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.move,
              onTapDown: (details) {
                startPosition = details.globalPosition;
                dragType.value = _DragType.all;
              },
              child: Container(
                width: (width ?? cellWidth * 0.3),
                height: cellHeight - 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: borderRadius,
                  shape: BoxShape.rectangle,
                ),
                child: child,
              ),
            ),
          ),
          Draggable(
            axis: Axis.horizontal,
            feedback:
                Container(color: Colors.white, width: 2, height: cellHeight),
            child: InkWell(
              onTapDown: (details) {
                startPosition = details.globalPosition;
                dragType.value = _DragType.endDate;
              },
              mouseCursor: SystemMouseCursors.resizeRight,
              hoverColor: Colors.white,
              child: Tooltip(
                message: "Change end date",
                child: SizedBox(width: _dragBordersHandleWidth, height: cellHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
