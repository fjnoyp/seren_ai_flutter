// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logging/logging.dart';
// import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
// import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
// import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

// final log = Logger('Gantt');

// // TODO: color assignment?

// // UI state for each task
// final ganttTaskUIStateProvider = StateNotifierProvider.family<
//     GanttTaskUIStateNotifier, GanttTaskUIState, String>(
//   (ref, taskId) => GanttTaskUIStateNotifier(taskId),
// );

// class GanttTaskUIState {
//   final bool isExpanded;
//   final bool isHighlighted;
//   final Color color;

//   //late Color? color;

//   GanttTaskUIState({
//     this.isExpanded = true,
//     this.isHighlighted = false,
//     this.color = Colors.grey,
//   });

//   GanttTaskUIState copyWith({
//     bool? isExpanded,
//     bool? isHighlighted,
//     Color? color,
//   }) {
//     return GanttTaskUIState(
//       isExpanded: isExpanded ?? this.isExpanded,
//       isHighlighted: isHighlighted ?? this.isHighlighted,
//       color: color ?? this.color,
//     );
//   }
// }

// class GanttTaskUIStateNotifier
//     extends FamilyNotifier<GanttTaskUIState, String> {
//   @override
//   GanttTaskUIState build(String taskId) {
//     // TODO p0: use below providers to get the top parent id
//     // And then the color of that top parent

//     return GanttTaskUIState();
//   }

//   void toggleExpanded() {
//     state = state.copyWith(isExpanded: !state.isExpanded);
//   }

//   void setColor(Color color) {
//     state = state.copyWith(color: color);
//   }
// }

// // TODO p3: double check this approach
// // In future if we do subset loads, we should be making these all SQL commands?
// // But we'd then have to deal with future methods ...
// // But we could load all relations without needing to load all tasks in ...
// final viewableTaskToChildIdsProvider =
//     Provider<Map<String, List<String>>>((ref) {
//   final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];
//   final Map<String, List<String>> childrenMap = {};

//   // Build children map
//   for (final task in tasks) {
//     if (task.parentTaskId != null) {
//       childrenMap.putIfAbsent(task.parentTaskId!, () => []).add(task.id);
//     }
//   }

//   return childrenMap;
// });

// final viewableIdToTasksProvider = Provider<Map<String, TaskModel>>((ref) {
//   final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];

//   final Map<String, TaskModel> idToTaskMap = {};
//   tasks.forEach((task) {
//     idToTaskMap[task.id] = task;
//   });

//   return idToTaskMap;
// });

// final viewableTaskToTopParentIdProvider = Provider<Map<String, String?>>((ref) {
//   final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];
//   final idToTaskMap = ref.watch(viewableIdToTasksProvider);

//   final Map<String, String?> topParentMap = {};

//   for (final task in tasks) {
//     var parentTaskId = task.parentTaskId;

//     while (parentTaskId != null) {
//       final parentTask = idToTaskMap[parentTaskId];
//       final nextParentTaskId = parentTask?.parentTaskId;

//       if (nextParentTaskId != null) {
//         parentTaskId = nextParentTaskId;
//       } else {
//         break;
//       }
//     }

//     topParentMap[task.id] = parentTaskId;
//   }

//   return topParentMap;
// });

// // Visible tasks provider
// // TODO p2: optimize
// final visibleGanttTasksProvider = Provider<List<TaskModel>>((ref) {
//   // TODO p0: simplify this to use the above providers, this should only focus on creating the proper
//   // ordering of tasks based on the children / parent relationships ...

//   final tasks = ref.watch(curUserViewableTasksStreamProvider).value ?? [];

//   // === Create Children Map ===
//   final Map<String, List<String>> childrenMap = {};
//   final Map<String, Color> taskColors = {};

//   final Map<String, TaskModel> idToTaskMap = {};
//   tasks.forEach((task) {
//     idToTaskMap[task.id] = task;
//   });

//   // Build children map
//   for (final task in tasks) {
//     if (task.parentTaskId != null) {
//       childrenMap.putIfAbsent(task.parentTaskId!, () => []).add(task.id);
//     }
//   }

//   // First, generate colors for all parent tasks
//   for (final task in tasks) {
//     if (task.parentTaskId == null) {
//       // Root task - generate new color
//       final colorValue = task.name.hashCode;
//       final hue = (colorValue % 360).abs().toDouble();
//       final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
//       taskColors[task.id] = color;
//     }
//   }

//   // TODO p3: doesn't support double nested task case ...
//   // We need to generate a sorted list of tasks ...
//   // Then, assign colors to child tasks
//   for (final task in tasks) {
//     if (task.parentTaskId != null) {
//       final targetColor = taskColors[task.id] ?? Colors.grey;
//       ref
//           .read(ganttTaskUIStateProvider(task.id).notifier)
//           .setColor(targetColor);
//       // Child task - use parent's color
//       taskColors[task.id] = taskColors[task.parentTaskId!]!;
//     }
//   }

//   final rootTasks = tasks.where((task) => task.parentTaskId == null).toList();

//   final List<TaskModel> visible = [];

//   void addTaskAndChildren(TaskModel task) {
//     visible.add(task);
//     if (ref.watch(ganttTaskUIStateProvider(task.id)).isExpanded) {
//       final childrenIds = childrenMap[task.id]!;
//       for (final childId in childrenIds) {
//         final childTask = idToTaskMap[childId];
//         if (childTask != null) {
//           addTaskAndChildren(childTask);
//         }
//       }
//     }
//   }

//   for (final task in rootTasks) {
//     addTaskAndChildren(task);
//   }

//   return visible;
// });
