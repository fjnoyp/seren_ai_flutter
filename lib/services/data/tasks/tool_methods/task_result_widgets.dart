import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/add_comment_to_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FindTasksResultWidget extends ConsumerWidget {
  final FindTasksResultModel result;
  const FindTasksResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context)!.foundTasks,
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (result.tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(AppLocalizations.of(context)!.noTasksFound),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result.tasks.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return TaskListItemView(
              task: result.tasks[index],
              showAssignees: isWebVersion,
              showMoreOptionsButton: false,
            );
          },
        ),
      ],
    );
  }
}

class CreateTaskResultWidget extends ConsumerWidget {
  final CreateTaskResultModel result;
  const CreateTaskResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Text(AppLocalizations.of(context)!
            .createdNewTaskAndOpenedTaskPage(result.task.name))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!
                  .createdNewTask(result.task.name)),
              TaskListItemView(task: result.task),
            ],
          );
  }
}

class UpdateTaskFieldsResultWidget extends ConsumerWidget {
  final UpdateTaskFieldsResultModel result;
  const UpdateTaskFieldsResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Text(AppLocalizations.of(context)!
            .updatedTaskAndShowedResultInUI(result.task.name))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.updatedTask(result.task.name)),
              TaskListItemView(task: result.task),
            ],
          );
  }
}

// Maybe we should create a base widget for simple results (like this and clock in/out) to keep layout consistency
class DeleteTaskResultWidget extends ConsumerWidget {
  final DeleteTaskResultModel result;
  const DeleteTaskResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Icon(Icons.check),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            switch (result.isDeleted) {
              true => AppLocalizations.of(context)!
                  .deletedTask(result.taskName ?? ''),
              false => AppLocalizations.of(context)!
                  .taskDeletionCancelledByUser(result.taskName ?? ''),
              _ => result.resultForAi,
            },
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class AddCommentToTaskResultWidget extends ConsumerWidget {
  final AddCommentToTaskResultModel result;
  const AddCommentToTaskResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Icon(Icons.chat_bubble_outline),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.task != null
                    ? 'Added comment to task "${result.task!.name}"'
                    : 'Added comment to task',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result.comment.content ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
