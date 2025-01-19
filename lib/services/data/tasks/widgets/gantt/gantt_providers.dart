import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';

// TODO : issue that gantt task data is regenerated on any change to task data
// and we have no way to update the gantt task data without re-generating it all ...

final visibleGanttTasksProvider = Provider<List<GanttTaskData>>((ref) {
  final taskData = ref.watch(_ganttTaskDataProvider);
  final visibleIds = ref.watch(visibleTaskIdsProvider);

  return visibleIds
      .map((id) => taskData[id])
      .whereType<GanttTaskData>()
      .toList();
});

class GanttTaskData {
  final String id;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> childrenIds;
  final String? parentId;
  final Color color;

  const GanttTaskData({
    required this.id,
    required this.title,
    this.startDate,
    this.endDate,
    required this.childrenIds,
    this.parentId,
    required this.color,
  });

  Duration? get duration => (startDate != null && endDate != null)
      ? endDate!.difference(startDate!)
      : null;
}

final _ganttTaskDataProvider = Provider<Map<String, GanttTaskData>>((ref) {
  final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];
  final Map<String, List<String>> childrenMap = {};
  final Map<String, Color> taskColors = {};

  // Build children map
  for (final task in tasks) {
    if (task.parentTaskId != null) {
      childrenMap.putIfAbsent(task.parentTaskId!, () => []).add(task.id);
    }
  }

  // First, generate colors for all parent tasks
  for (final task in tasks) {
    if (task.parentTaskId == null) {
      // Root task - generate new color
      final colorValue = task.name.hashCode;
      final hue = (colorValue % 360).abs().toDouble();
      final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
      taskColors[task.id] = color;
    }
  }

  // Then, assign colors to child tasks
  for (final task in tasks) {
    if (task.parentTaskId != null) {
      // Child task - use parent's color
      taskColors[task.id] = taskColors[task.parentTaskId!]!;
    }
  }

  // Convert to GanttTaskData
  return {
    for (final task in tasks)
      task.id: GanttTaskData(
        id: task.id,
        title: task.name,
        startDate: task.startDateTime,
        endDate: task.dueDate,
        childrenIds: childrenMap[task.id] ?? [],
        parentId: task.parentTaskId,
        color: taskColors[task.id]!,
      )
  };
});

// UI state for each task
final ganttTaskUIStateProvider = StateNotifierProvider.family<
    GanttTaskUIStateNotifier, GanttTaskUIState, String>(
  (ref, taskId) => GanttTaskUIStateNotifier(),
);

class GanttTaskUIState {
  final bool isExpanded;
  final bool isHighlighted;

  const GanttTaskUIState({
    this.isExpanded = true,
    this.isHighlighted = false,
  });
}

class GanttTaskUIStateNotifier extends StateNotifier<GanttTaskUIState> {
  GanttTaskUIStateNotifier() : super(const GanttTaskUIState());

  void toggleExpanded() {
    state = GanttTaskUIState(isExpanded: !state.isExpanded);
  }
}

// Visible tasks provider
final visibleTaskIdsProvider = Provider<List<String>>((ref) {
  final taskData = ref.watch(_ganttTaskDataProvider);
  final rootTasks =
      taskData.values.where((task) => task.parentId == null).toList();
  final List<String> visible = [];

  void addTaskAndChildren(GanttTaskData task) {
    visible.add(task.id);
    if (ref.watch(ganttTaskUIStateProvider(task.id)).isExpanded) {
      for (final childId in task.childrenIds) {
        final childTask = taskData[childId];
        if (childTask != null) {
          addTaskAndChildren(childTask);
        }
      }
    }
  }

  for (final task in rootTasks) {
    addTaskAndChildren(task);
  }

  return visible;
});
