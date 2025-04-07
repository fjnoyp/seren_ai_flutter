import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

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
  if (projectId == null) return {};

  final filteredTasks =
      ref.watch(tasksAndParentsByProjectFilteredProvider(projectId)).value ??
          [];

  // Build hierarchy map including all necessary tasks
  final hierarchyMap = <String, TaskHierarchyInfo>{};

  // Add all required tasks to the hierarchy map
  for (final task in filteredTasks) {
    hierarchyMap[task.id] = TaskHierarchyInfo(
      taskId: task.id,
      parentId: task.parentTaskId,
      childrenIds: [], // Filled in next pass
      depth: 0, // Calculated in next pass
    );
  }

  // Build relationships
  for (final task in filteredTasks) {
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

  Map<String, TaskHierarchyInfo> sortTasks(
      int Function(TaskModel, TaskModel) sortComparator) {
    final curInlineCreatingTaskId = ref.watch(curInlineCreatingTaskIdProvider);

    // Sort children for each parent
    for (final info in hierarchyMap.values) {
      info.childrenIds.sort((a, b) {
        // If we are creating a new task, move it to the top
        if (a == curInlineCreatingTaskId) {
          return -1;
        }
        if (b == curInlineCreatingTaskId) {
          return 1;
        }
        final taskA = filteredTasks.firstWhere((t) => t.id == a);
        final taskB = filteredTasks.firstWhere((t) => t.id == b);
        return sortComparator(taskA, taskB);
      });
    }

    // Sort root tasks
    final rootTasks =
        filteredTasks.where((t) => t.parentTaskId == null).toList();
    rootTasks.sort((a, b) {
      // If we are creating a new task or phase, move it to the top
      if (a.id == curInlineCreatingTaskId) {
        return -1;
      }
      if (b.id == curInlineCreatingTaskId) {
        return 1;
      }
      // First, group by type (tasks before phases)
      if (a.isPhase != b.isPhase) {
        return a.isPhase
            ? 1
            : -1; // Non-phases (false) come before phases (true)
      }
      // Within each group, sort by priority using the existing comparator
      return sortComparator(a, b);
    });

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
  }

  final filterState =
      ref.watch(taskFilterStateProvider(TaskFilterViewType.projectOverview));

  // Sort both root tasks and children lists according to the sort preference
  if (filterState.sortComparator != null) {
    return sortTasks(filterState.sortComparator!);
  } else {
    // If no sort comparator is set, sort alphabetically
    return sortTasks((a, b) => a.name.compareTo(b.name));
  }
});

// dark modern

final curProjectTasksHierarchyNumberedProvider =
    Provider<List<({String rowNumber, String taskId})>>((ref) {
  final taskIds = ref.watch(curProjectTasksHierarchyIdsProvider);
  final hierarchy = ref.watch(_curProjectTasksHierarchyProvider);

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
