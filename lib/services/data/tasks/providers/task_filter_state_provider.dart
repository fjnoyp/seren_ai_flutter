import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/task_filter_option_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/task_sort_option_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class TaskFilterState {
  final String searchQuery;
  final TaskSortOption? sortBy;
  final List<
      ({
        String? value,
        String? name,
        bool Function(TaskModel)? filter,
      })?> filterBy;

  const TaskFilterState({
    this.searchQuery = '',
    this.sortBy,
    required this.filterBy,
  });

  TaskFilterState copyWith({
    String? searchQuery,
    TaskSortOption? sortBy,
    List<
            ({
              String? value,
              String? name,
              bool Function(TaskModel)? filter,
            })?>?
        filterBy,
  }) {
    return TaskFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      filterBy: filterBy ?? this.filterBy,
    );
  }

  bool Function(TaskModel) get filterCondition => (task) {
        bool result = true;

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          result = task.name.toLowerCase().contains(searchQuery.toLowerCase());
        }

        // Apply other filters
        for (var filter in filterBy) {
          if (filter?.filter != null) {
            result = result && filter!.filter!(task);
          }
        }

        return result;
      };

  Comparator<TaskModel>? get sortComparator => sortBy?.comparator;
}

class TaskFilterStateNotifier extends StateNotifier<TaskFilterState> {
  TaskFilterStateNotifier()
      : super(TaskFilterState(
          filterBy: TaskFilterOption.values.map((_) => null).toList(),
        ));

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSortOption(TaskSortOption? option) {
    state = state.copyWith(sortBy: option);
  }

  void updateFilter(
      int index,
      ({
        String? value,
        String? name,
        bool Function(TaskModel)? filter,
      })? filter) {
    final newFilters = [...state.filterBy];
    newFilters[index] = filter;
    state = state.copyWith(filterBy: newFilters);
  }

  void clearFilters() {
    state = TaskFilterState(
      filterBy: TaskFilterOption.values.map((_) => null).toList(),
    );
  }
}

final taskFilterStateProvider =
    StateNotifierProvider.autoDispose<TaskFilterStateNotifier, TaskFilterState>(
        (ref) => TaskFilterStateNotifier());
