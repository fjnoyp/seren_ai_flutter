import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO p0: reuse task list item display if possible ...

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
    return Text(result.resultForAi);
  }
}

class UpdateTaskFieldsResultWidget extends ConsumerWidget {
  final UpdateTaskFieldsResultModel result;
  const UpdateTaskFieldsResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(result.resultForAi);
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
            result.resultForAi,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
