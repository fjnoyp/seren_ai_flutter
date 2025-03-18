import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_card_item_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A simplified task list view that uses the tasksFilteredProvider
/// and optionally applies an additional filter
class TasksFilteredListView extends ConsumerWidget {
  const TasksFilteredListView({
    super.key,
    this.additionalFilter,
    this.onTapTask,
    this.emptyStateWidget,
    this.projectId,
    this.itemBuilder,
    this.separatorBuilder,
    required this.viewType,
  });

  /// Optional additional filter beyond what's in the tasksFilteredProvider
  final bool Function(TaskModel task)? additionalFilter;

  /// Callback when a task is tapped
  final void Function(String taskId)? onTapTask;

  /// Widget to show when no tasks match the filters
  final Widget? emptyStateWidget;

  /// The project id to filter tasks by
  final String? projectId;

  /// Builder function to create the task item widget
  /// If not provided, defaults to TaskListTileItemView
  final Widget Function(TaskModel task, void Function(String taskId)? onTap)?
      itemBuilder;

  /// Builder function to create the separator between items
  /// If not provided, defaults to a simple Divider
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// The view type to use for the tasksFilteredProvider
  final TaskFilterViewType viewType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note on performance optimization:
    // We could have used the tasksFilteredProvider directly, but retrieving tasks
    // from tasksByProjectsFilteredProvider is more efficient because:
    // 1. It fetches only the specific project tasks from the repository instead of all tasks
    // 2. This reduces data transfer and memory usage by loading only what's needed
    // 3. The filtering happens at the data source level (database/repository) where it can
    //    potentially use indexes and optimized query mechanisms
    // 4. It avoids the computational overhead of filtering a larger dataset in the application
    final filteredTasks = projectId != null &&
            !CurSelectedProjectIdNotifier.isEverythingId(projectId!)
        ? ref.watch(tasksByProjectFilteredProvider(projectId!))
        : ref.watch(tasksFilteredProvider(viewType));

    // Apply additional filter if provided
    final tasks = additionalFilter != null
        ? filteredTasks.where(additionalFilter!).toList()
        : filteredTasks;

    // Show empty state if no tasks match the filter
    if (tasks.isEmpty) {
      return emptyStateWidget ??
          Center(
            child: Text(
              AppLocalizations.of(context)?.noTasksFound ?? 'No tasks found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
    }

    // Display the tasks
    return ListView.separated(
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return itemBuilder != null
            ? itemBuilder!(task, onTapTask)
            : TaskListCardItemView(
                task: task,
                onTap: onTapTask,
              );
      },
      separatorBuilder:
          separatorBuilder ?? (context, index) => const Divider(height: 1),
    );
  }
}
