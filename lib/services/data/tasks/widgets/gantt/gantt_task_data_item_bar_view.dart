import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_providers.dart';

class GanttTaskDataItemBarView extends ConsumerWidget {
  final GanttTaskData task;
  final double cellWidth;
  final double cellHeight;
  final int columnStartDay;

  const GanttTaskDataItemBarView({
    super.key,
    required this.task,
    required this.cellWidth,
    required this.cellHeight,
    required this.columnStartDay,
  });

  double _calculateEventPosition(DateTime date) {
    final startDate = DateTime.now().add(Duration(days: columnStartDay));
    return date.difference(startDate).inDays * cellWidth;
  }

  Widget _buildTaskContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        if (task.childrenIds.isNotEmpty)
          Consumer(
            builder: (context, ref, _) {
              final isExpanded =
                  ref.watch(ganttTaskUIStateProvider(task.id)).isExpanded;
              return IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
                onPressed: () => ref
                    .read(ganttTaskUIStateProvider(task.id).notifier)
                    .toggleExpanded(),
              );
            },
          ),
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasStartDate = task.startDate != null;
    final hasEndDate = task.endDate != null;
    final hasDuration = task.duration != null;

    Widget taskWidget;
    double leftPosition = 0;

    if (hasDuration) {
      // Complete task bar
      leftPosition = _calculateEventPosition(task.startDate!);
      taskWidget = _CompleteTaskBar(
        task: task,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
      );
    } else if (hasStartDate || hasEndDate) {
      // Partial task indicator
      final date = hasStartDate ? task.startDate! : task.endDate!;
      leftPosition = _calculateEventPosition(date);
      final isStart = hasStartDate;

      taskWidget = _TaskContainer(
        width: cellWidth,
        color: task.color,
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
      // Error indicator
      taskWidget = _TaskContainer(
        width: cellWidth,
        color: Colors.red,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        child: const Center(
          child: Text(
            'Error: No dates',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Positioned(
      left: leftPosition,
      top: 5,
      child: taskWidget,
    );
  }
}

class _CompleteTaskBar extends StatelessWidget {
  final GanttTaskData task;
  final double cellWidth;
  final double cellHeight;

  const _CompleteTaskBar({
    required this.task,
    required this.cellWidth,
    required this.cellHeight,
  });

  Widget _buildTaskContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        if (task.childrenIds.isNotEmpty)
          Consumer(
            builder: (context, ref, _) {
              final isExpanded =
                  ref.watch(ganttTaskUIStateProvider(task.id)).isExpanded;
              return IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
                onPressed: () => ref
                    .read(ganttTaskUIStateProvider(task.id).notifier)
                    .toggleExpanded(),
              );
            },
          ),
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TaskContainer(
      width: task.duration!.inDays * cellWidth,
      color: task.color,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      borderRadius: BorderRadius.circular(4),
      child: _buildTaskContent(),
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
