import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_card_item_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A simple task list view that takes a list of tasks and displays them
class TaskListView extends ConsumerWidget {
  const TaskListView({
    super.key,
    required this.tasks,
    this.onTapTask,
    this.emptyStateWidget,
    this.itemBuilder,
    this.separatorBuilder,
    this.additionalFilter,
  });

  /// The list of tasks to display
  final List<TaskModel> tasks;

  /// Callback when a task is tapped
  final void Function(String taskId)? onTapTask;

  /// Widget to show when no tasks match the filters
  final Widget? emptyStateWidget;

  /// Builder function to create the task item widget
  /// If not provided, defaults to TaskListTileItemView
  final Widget Function(TaskModel task, void Function(String taskId)? onTap)?
      itemBuilder;

  /// Builder function to create the separator between items
  /// If not provided, defaults to a simple Divider
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Optional filter to apply to the tasks
  final bool Function(TaskModel task)? additionalFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Apply additional filter if provided
    final filteredTasks = additionalFilter != null
        ? tasks.where(additionalFilter!).toList()
        : tasks;

    // Show empty state if no tasks match the filter
    if (filteredTasks.isEmpty) {
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
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
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
