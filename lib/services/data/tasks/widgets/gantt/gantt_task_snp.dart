import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';

// State class to hold all Gantt-related data
class GanttState {
  final List<GanttTask> tasks;

  GanttState({
    required this.tasks,
  });

  GanttState copyWith({
    List<GanttTask>? tasks,
  }) {
    return GanttState(
      tasks: tasks ?? this.tasks,
    );
  }
}

class GanttTask {
  final TaskModel task;
  final List<GanttTask> children;
  final bool isHidden;
  final Color color;
  final bool isHighlighted;

  GanttTask({
    required this.task,
    required this.children,
    required this.isHidden,
    required this.color,
    required this.isHighlighted,
  });
}

final ganttTaskProvider =
    StateNotifierProvider<GanttTaskNotifier, GanttState>((ref) {
  final notifier = GanttTaskNotifier();

  // Watch for changes to tasks and update the Gantt state
  ref.listen(curUserViewableTasksStreamProvider, (previous, next) {
    if (next.hasValue && next.value != null) {
      notifier.processTaskData(next.value!);
    }
  });

  return notifier;
});

class GanttTaskNotifier extends StateNotifier<GanttState> {
  GanttTaskNotifier()
      : super(GanttState(
          tasks: [],
        ));

  void processTaskData(List<TaskModel> rawTasks) {
    if (rawTasks.isEmpty) return;

    // Group and sort tasks
    final Map<String?, List<TaskModel>> tasksByParent = {};

    // First pass - group tasks by parentId
    for (final task in rawTasks) {
      final parentId = task.parentTaskId;
      tasksByParent.putIfAbsent(parentId, () => []).add(task);
    }

    // Process root tasks (tasks with no parent)
    final rootTasks = tasksByParent[null] ?? [];
    rootTasks.sort((a, b) {
      final aDate = a.startDateTime;
      final bDate = b.startDateTime;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    // Convert to GanttTask structure
    List<GanttTask> convertedTasks =
        _convertToGanttTasks(rootTasks, tasksByParent);

    state = GanttState(
      tasks: convertedTasks,
    );
  }

  List<GanttTask> _convertToGanttTasks(
    List<TaskModel> tasks,
    Map<String?, List<TaskModel>> tasksByParent,
  ) {
    return tasks.map((task) {
      final children = tasksByParent[task.id] ?? [];
      final taskStartDate = task.startDateTime;
      final taskDueDate = task.dueDate;
      final isAfterStartDate = taskStartDate != null;
      final isBeforeDueDate = taskDueDate != null;
      final isHighlighted = isAfterStartDate && isBeforeDueDate;

      // Generate consistent color based on task name
      final taskName = task.name;
      final colorValue = taskName.hashCode;
      final hue = (colorValue % 360).abs().toDouble();
      final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();

      children.sort((a, b) {
        final aDate = a.startDateTime;
        final bDate = b.startDateTime;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

      return GanttTask(
        task: task,
        children: _convertToGanttTasks(children, tasksByParent),
        isHidden: false,
        color: color, // Consistent color based on task name
        isHighlighted: isHighlighted,
      );
    }).toList();
  }
}
