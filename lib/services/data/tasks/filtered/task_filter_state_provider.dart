import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_user_viewable_tasks_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_filter.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

class TaskFilterState {
  final String searchQuery;
  final TaskFieldEnum? sortBy;
  final List<TaskFilter> activeFilters;

  const TaskFilterState({
    this.searchQuery = '',
    this.sortBy,
    required this.activeFilters,
  });

  TaskFilterState copyWith({
    String? searchQuery,
    TaskFieldEnum? sortBy,
    List<TaskFilter>? activeFilters,
  }) {
    return TaskFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }

  bool Function(TaskModel) get filterCondition => (task) {
        // Apply search filter
        if (searchQuery.isNotEmpty) {
          final searchResult =
              task.name.toLowerCase().contains(searchQuery.toLowerCase());
          if (!searchResult) return false;
        }

        // Apply other filters
        for (var filter in activeFilters) {
          if (filter.condition != null) {
            final result = filter.condition!(task);
            if (!result) return false;
          }
        }

        return true;
      };

  Comparator<TaskModel>? get sortComparator => sortBy?.comparator;
}

class TaskFilterStateNotifier extends StateNotifier<TaskFilterState> {
  // TODO p2: find a better way to initialize the filters
  // We want the type filter to be active for "tasks" by default
  TaskFilterStateNotifier(BuildContext context)
      : super(
          TaskFilterState(
            activeFilters: [
              TaskFilter(
                  field: TaskFieldEnum.type,
                  value: TaskType.task.name,
                  readableName: TaskType.task.toHumanReadable(context),
                  condition: (task) => task.type == TaskType.task)
            ],
          ),
        );

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSortOption(TaskFieldEnum? option) {
    if (option == null) {
      final curState = state;
      state = TaskFilterState(
        searchQuery: curState.searchQuery,
        sortBy: null,
        activeFilters: curState.activeFilters,
      );
    } else {
      state = state.copyWith(sortBy: option);
    }
  }

  /// Updates the filter state with a new filter
  /// If the filter already exists, it will be updated
  /// Otherwise, it will be added
  ///
  /// We should switch to add filters of the same type in future, to allow multiple selection
  void updateFilter(TaskFilter newFilter) {
    // If the filter already exists, update it
    if (state.activeFilters.any((f) => f.field == newFilter.field)) {
      final newFilters = state.activeFilters
          .map((f) => f.field == newFilter.field ? newFilter : f)
          .toList();
      state = state.copyWith(activeFilters: newFilters);
      return;
    }

    // Otherwise, add the filter
    state = state.copyWith(activeFilters: [...state.activeFilters, newFilter]);
  }

  void removeFilter(TaskFieldEnum field) {
    final newFilters =
        state.activeFilters.where((f) => f.field != field).toList();
    state = state.copyWith(activeFilters: newFilters);
  }
}

final taskFilterStateProvider =
    StateNotifierProvider<TaskFilterStateNotifier, TaskFilterState>((ref) {
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;
  return TaskFilterStateNotifier(context);
});
