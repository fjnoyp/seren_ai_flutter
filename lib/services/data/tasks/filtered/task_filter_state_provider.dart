import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_filter.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

class TaskFilterState {
  final TaskFieldEnum? sortBy;
  final List<TaskFilter> activeFilters;

  const TaskFilterState({
    this.sortBy,
    required this.activeFilters,
  });

  TaskFilterState copyWith({
    String? searchQuery,
    TaskFieldEnum? sortBy,
    List<TaskFilter>? activeFilters,
  }) {
    return TaskFilterState(
      sortBy: sortBy ?? this.sortBy,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }

  bool Function(TaskModel) get filterCondition => (task) {
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
  TaskFilterStateNotifier(BuildContext context, TaskFilterViewType viewType)
      : super(_getInitialState(context, viewType));

  static TaskFilterState _getInitialState(
      BuildContext context, TaskFilterViewType viewType) {
    final tasksOnlyFilter = TaskFilter(
      field: TaskFieldEnum.type,
      readableName: TaskType.task.toHumanReadable(context),
      condition: (task) => task.type == TaskType.task,
    );

    // Return different initial states based on the view type
    switch (viewType) {
      case TaskFilterViewType.modalSearch:
        // No default filters for search for now
        return const TaskFilterState(activeFilters: []);
      case TaskFilterViewType.projectOverview:
        return TaskFilterState(activeFilters: [tasksOnlyFilter]);
      case TaskFilterViewType.phaseSubtasks:
        return TaskFilterState(activeFilters: [tasksOnlyFilter]);
    }
  }

  void updateSortOption(TaskFieldEnum? option) {
    if (option == null) {
      final curState = state;
      state = TaskFilterState(
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

  void clearAllFilters() {
    state = state.copyWith(activeFilters: []);
  }
}

final taskFilterStateProvider = StateNotifierProvider.family
    .autoDispose<TaskFilterStateNotifier, TaskFilterState, TaskFilterViewType>(
        (ref, viewType) {
  final context =
      ref.read(navigationServiceProvider).navigatorKey.currentContext!;

  return TaskFilterStateNotifier(context, viewType);
});
