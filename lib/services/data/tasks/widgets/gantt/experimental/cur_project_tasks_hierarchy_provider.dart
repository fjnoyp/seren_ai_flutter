import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';

class TaskHierarchyInfo {
  final String taskId;
  final String? parentId;
  final List<String> childrenIds;
  int depth;

  TaskHierarchyInfo({
    required this.taskId,
    this.parentId,
    List<String>? childrenIds,
    this.depth = 0,
  }) : childrenIds = childrenIds ?? [];
}

/// Provide ids of cur project tasks sorted by hierarchy (tasks grouped together by hierarhcy)
final curProjectTasksHierarchyIdsProvider = Provider<List<String>>((ref) {
  final hierarchy = ref.watch(_curProjectTasksHierarchyProvider);

  // Collect task IDs in the order defined by the hierarchy
  List<String> orderedTaskIds = [];

  void addTasksInOrder(String taskId) {
    orderedTaskIds.add(taskId);
    for (final childId in hierarchy[taskId]?.childrenIds ?? []) {
      addTasksInOrder(childId);
    }
  }

  // Start with root tasks
  for (final taskId
      in hierarchy.keys.where((id) => hierarchy[id]?.parentId == null)) {
    addTasksInOrder(taskId);
  }

  return orderedTaskIds;
});

/// Provide hierarchy info for a taskId
final taskHierarchyInfoProvider =
    Provider.autoDispose.family<TaskHierarchyInfo?, String>((ref, taskId) {
  // Use select() to only watch the specific map entry
  return ref
      .watch(_curProjectTasksHierarchyProvider.select((map) => map[taskId]));
});

// Provide top level parentId for a given taskId
final taskParentChainIdsProvider =
    Provider.autoDispose.family<List<String>, String>((ref, taskId) {
  final chain = <String>[];
  String? currentId = taskId;

  while (currentId != null) {
    final info = ref.watch(
        _curProjectTasksHierarchyProvider.select((map) => map[currentId]));
    currentId = info?.parentId;
    if (currentId != null) {
      chain.add(currentId);
    }
  }

  return chain;
});

// TODO p3: make this a family provider so we can use it to get hierarchy for all tasks (projectId == null)
// Return tasks in their hierarchal groupings
final _curProjectTasksHierarchyProvider =
    Provider<Map<String, TaskHierarchyInfo>>((ref) {
  final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
  final tasks = ref
          .watch(projectId == null
              ? curUserViewableTasksStreamProvider
              : tasksByProjectStreamProvider(projectId))
          .value ??
      [];

  // Build hierarchy map for O(1) lookups
  final hierarchyMap = <String, TaskHierarchyInfo>{};

  for (final task in tasks) {
    hierarchyMap[task.id] = TaskHierarchyInfo(
      taskId: task.id,
      parentId: task.parentTaskId,
      childrenIds: [], // Filled in next pass
      depth: 0, // Calculated in next pass
    );
  }

  // Second pass to build relationships
  for (final task in tasks) {
    if (task.parentTaskId != null) {
      hierarchyMap[task.parentTaskId]?.childrenIds.add(task.id);
    }
  }

  // Calculate depths
  void calculateDepth(String taskId, int depth) {
    hierarchyMap[taskId]?.depth = depth;
    for (final childId in hierarchyMap[taskId]?.childrenIds ?? []) {
      calculateDepth(childId, depth + 1);
    }
  }

  // Calculate depths starting from root tasks
  for (final task in tasks.where((t) => t.parentTaskId == null)) {
    calculateDepth(task.id, 0);
  }

  return hierarchyMap;
});

// dark modern
