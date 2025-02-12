import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class TaskFilterState {
  final String searchQuery;
  final TaskSortOption? sortBy;
  final Map<
      int,
      ({
        String? value,
        String? name,
        bool Function(TaskModel)? filter,
      })> activeFilters;

  const TaskFilterState({
    this.searchQuery = '',
    this.sortBy,
    required this.activeFilters,
  });

  TaskFilterState copyWith({
    String? searchQuery,
    TaskSortOption? sortBy,
    Map<
            int,
            ({
              String? value,
              String? name,
              bool Function(TaskModel)? filter,
            })>?
        activeFilters,
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
        for (var entry in activeFilters.entries) {
          if (entry.value.filter != null) {
            final result = entry.value.filter!(task);
            if (!result) return false;
          }
        }

        return true;
      };

  Comparator<TaskModel>? get sortComparator => sortBy?.comparator;
}

class TaskFilterStateNotifier extends StateNotifier<TaskFilterState> {
  // TODO p2: find a better way to initialize the filters
  TaskFilterStateNotifier(BuildContext context)
      : super(
          TaskFilterState(
            activeFilters: {
              0: (
                value: '${TaskFilterOption.type.name}_${TaskType.task.name}',
                name:
                    '${TaskFilterOption.type.getDisplayName(context)}: ${TaskType.task.toHumanReadable(context)}',
                filter: (task) => task.type == TaskType.task
              )
            },
          ),
        );

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSortOption(TaskSortOption? option) {
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

  void updateFilter(
      int index,
      ({
        String? value,
        String? name,
        bool Function(TaskModel)? filter,
      })? filter) {
    final newFilters = Map<
        int,
        ({
          String? value,
          String? name,
          bool Function(TaskModel)? filter,
        })>.from(state.activeFilters);

    if (filter != null) {
      newFilters[index] = filter; // Add or update filter
    } else {
      newFilters.remove(index); // Remove filter if null
    }

    state = state.copyWith(activeFilters: newFilters);
  }

  void clearFilters() => state = const TaskFilterState(activeFilters: {});
}

final taskFilterStateProvider =
    StateNotifierProvider.autoDispose<TaskFilterStateNotifier, TaskFilterState>(
        (ref) {
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;
  return TaskFilterStateNotifier(context);
});
