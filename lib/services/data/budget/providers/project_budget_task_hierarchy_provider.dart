import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';

final _curProjectBudgetTasksHierarchyProvider =
    Provider<Map<String, TaskHierarchyInfo>>((ref) {
  final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
  if (projectId == null) return {};

  final tasks = ref.watch(tasksByProjectStreamProvider(projectId)).value ?? [];

  // Build hierarchy map including all necessary tasks
  final hierarchyMap = <String, TaskHierarchyInfo>{};

  // Add all required tasks to the hierarchy map
  for (final task in tasks) {
    hierarchyMap[task.id] = TaskHierarchyInfo(
      taskId: task.id,
      parentId: task.parentTaskId,
      childrenIds: [], // Filled in next pass
      depth: 0, // Calculated in next pass
    );
  }

  // Build relationships
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

  // Sort comparator for tasks on project budget table
  int sortComparator(a, b) => (a.startDateTime ?? a.createdAt ?? DateTime.now())
      .compareTo(b.startDateTime ?? b.createdAt ?? DateTime.now());

  // Sort children for each parent
  for (final info in hierarchyMap.values) {
    info.childrenIds.sort((a, b) {
      final taskA = tasks.firstWhere((t) => t.id == a);
      final taskB = tasks.firstWhere((t) => t.id == b);
      return sortComparator(taskA, taskB);
    });
  }

  // Sort root tasks
  final rootTasks = tasks.where((t) => t.parentTaskId == null).toList();
  rootTasks.sort(sortComparator);

  // Rebuild the map in the correct order
  final sortedMap = <String, TaskHierarchyInfo>{};

  // Add root tasks first in sorted order
  for (final task in rootTasks) {
    sortedMap[task.id] = hierarchyMap[task.id]!;
  }

  // Add remaining tasks
  for (final entry in hierarchyMap.entries) {
    if (!sortedMap.containsKey(entry.key)) {
      sortedMap[entry.key] = entry.value;
    }
  }

  // Update depths based on the sorted order
  for (final task in rootTasks) {
    calculateDepth(task.id, 0);
  }

  return sortedMap;
});

final curProjectTasksHierarchyNumberedProvider =
    Provider<List<({String rowNumber, String taskId})>>((ref) {
  final hierarchy = ref.watch(_curProjectBudgetTasksHierarchyProvider);

  // Collect task IDs in the order defined by the hierarchy
  final taskIds = <String>[];

  void addTasksInOrder(String taskId) {
    taskIds.add(taskId);
    for (final childId in hierarchy[taskId]?.childrenIds ?? []) {
      addTasksInOrder(childId);
    }
  }

  // Start with root tasks
  for (final taskId
      in hierarchy.keys.where((id) => hierarchy[id]?.parentId == null)) {
    addTasksInOrder(taskId);
  }

  final result = <({String rowNumber, String taskId})>[];
  final rootTaskCounter = <String, int>{};

  // Helper function to generate hierarchical numbering
  String generateTaskNumber(String taskId) {
    final info = hierarchy[taskId];
    if (info == null) return '';

    // For root tasks (depth = 0)
    if (info.depth == 0) {
      // Count root tasks in order of appearance
      final rootCount = (rootTaskCounter.length + 1);
      rootTaskCounter[taskId] = rootCount;
      return rootCount.toString();
    } else {
      // For child tasks, get parent's number and append child index
      final parentId = info.parentId;
      if (parentId == null) return ''; // Shouldn't happen if depth > 0

      final parentNumber = result
          .firstWhere((item) => item.taskId == parentId,
              orElse: () => (rowNumber: '', taskId: ''))
          .rowNumber;

      if (parentNumber.isEmpty) return '';

      // Find position of this task in parent's children list
      final childIndex = hierarchy[parentId]?.childrenIds.indexOf(taskId) ?? -1;
      if (childIndex == -1) return '';

      return '$parentNumber.${childIndex + 1}';
    }
  }

  // Process tasks in the order provided by curProjectTasksHierarchyIdsProvider
  for (final taskId in taskIds) {
    final taskNumber = generateTaskNumber(taskId);
    result.add((rowNumber: taskNumber, taskId: taskId));
  }

  return result;
});
