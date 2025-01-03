import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
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
        ...result.tasks.map((task) {
          return TaskListItemView(joinedTask: task);
        }),
      ],
    );
  }
}

class CreateTaskResultWidget extends ConsumerWidget {
  final CreateTaskResultModel result;
  const CreateTaskResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Text(AppLocalizations.of(context)!
            .createdNewTaskAndOpenedTaskPage(result.joinedTask.task.name))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!
                  .createdNewTask(result.joinedTask.task.name)),
              TaskListItemView(joinedTask: result.joinedTask),
            ],
          );
  }
}

class UpdateTaskFieldsResultWidget extends ConsumerWidget {
  final UpdateTaskFieldsResultModel result;
  const UpdateTaskFieldsResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Text(AppLocalizations.of(context)!
            .updatedTaskAndShowedResultInUI(result.joinedTask.task.name))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!
                  .updatedTask(result.joinedTask.task.name)),
              TaskListItemView(joinedTask: result.joinedTask),
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
            },
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
