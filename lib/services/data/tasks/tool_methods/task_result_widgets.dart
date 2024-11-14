import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

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
        Text('Found Tasks', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (result.tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text('No tasks found'),
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