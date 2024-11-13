import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';

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
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.task,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.task.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  if (task.task.description != null && task.task.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                      child: Text(
                        task.task.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                    child: Row(
                      children: [
                        Text(
                          'Status: ${task.task.status}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Priority: ${task.task.priority}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
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
