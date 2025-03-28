import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_similarity_extension.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

// Provider to store the current search query
final taskSearchQueryProvider =
    StateProvider.family<String, TaskFilterViewType>((ref, viewType) => '');

// Provider to make filtered tasks available with proper refresh behavior
final tasksFilteredSearchProvider = FutureProvider.autoDispose
    .family<List<TaskModel>, TaskFilterViewType>((ref, viewType) async {
  final searchService = ref.watch(tasksFilteredSearchServiceProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider(viewType));

  // This causes the provider to refresh when the search query changes
  ref.watch(taskFilterStateProvider(viewType));

  return searchService.getFilteredTasks(
    viewType: viewType,
    searchQuery: searchQuery,
  );
});

/// Provider that gives access to the TasksFilteredSearchService
final tasksFilteredSearchServiceProvider = Provider((ref) {
  return TasksFilteredSearchService(ref);
});

/// Service class that handles filtering and searching tasks
class TasksFilteredSearchService {
  final Ref _ref;

  TasksFilteredSearchService(this._ref);

  /// Get filtered tasks based on viewType and optional search query
  ///
  /// [viewType] - The task filter view type
  /// [searchQuery] - Optional text to search for in tasks
  /// Returns a Future with a list of filtered and/or searched tasks

  // TODO p3: once more tasks are added this might have performance issues - we then need to switch to a db based FTS + semantic search
  Future<List<TaskModel>> getFilteredTasks({
    required TaskFilterViewType viewType,
    String? searchQuery,
  }) async {
    // Get current user and org
    final user = _ref.read(curUserProvider).valueOrNull;
    final orgId = _ref.read(curSelectedOrgIdNotifierProvider);

    if (user == null || orgId == null) {
      return [];
    }

    // Get tasks using the repository's get method
    final tasks = await _ref.read(tasksRepositoryProvider).getUserViewableTasks(
          userId: user.id,
          orgId: orgId,
        );

    final filterState = _ref.read(taskFilterStateProvider(viewType));

    // Apply async filtering with proper error handling
    final asyncResults = await Future.wait(
      tasks.map((task) async {
        try {
          final matches = await filterState.asyncFilterCondition(task);
          return matches ? task : null;
        } catch (e) {
          debugPrint('Error in async filter for task ${task.id}: $e');
          return null;
        }
      }),
    );

    var filteredTasks = asyncResults.whereType<TaskModel>().toList();

    // Apply sorting if provided
    if (filterState.sortComparator != null) {
      filteredTasks.sort(filterState.sortComparator!);
    }
    // Apply text search if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Use string similarity extension for fuzzy matching
      const double similarityThreshold = 0.35;

      // Create a list of tasks with their similarity scores
      final scoredTasks = filteredTasks.map((task) {
        // Calculate the highest similarity score between name and description
        double nameSimilarity = task.name.similarity(searchQuery);
        double descSimilarity = task.description != null
            ? task.description!.similarity(searchQuery)
            : 0.0;

        // Use the higher of the two scores
        double highestSimilarity = max(nameSimilarity, descSimilarity);

        return (task: task, similarity: highestSimilarity);
      }).where((scored) {
        // Filter out tasks with similarity below threshold
        return scored.similarity >= similarityThreshold;
      }).toList();

      // Sort by similarity score (highest to lowest)
      scoredTasks.sort((a, b) => b.similarity.compareTo(a.similarity));

      // Extract just the tasks from the scored list
      filteredTasks = scoredTasks.map((scored) => scored.task).toList();
    }

    return filteredTasks;
  }
}
