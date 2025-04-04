import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/add_comment_to_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ai_tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_card_item_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FindTasksResultWidget extends ConsumerWidget {
  final FindTasksResultModel result;
  const FindTasksResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Build search criteria widget if in English language
    Widget? searchCriteriaWidget;
    if (isEnglish && result.searchCriteria.isNotEmpty) {
      searchCriteriaWidget = Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search criteria:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...result.searchCriteria.entries.map((entry) {
              if (entry.value is Map) {
                // For date ranges and other nested maps
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ${entry.key}:',
                        style: theme.textTheme.bodyMedium,
                      ),
                      ...Map<String, dynamic>.from(entry.value)
                          .entries
                          .map((subEntry) => Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  '${subEntry.key}: ${subEntry.value}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                );
              } else if (entry.value is List) {
                // For lists like assignees
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '• ${entry.key}: ${(entry.value as List).join(', ')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              } else {
                // For simple values
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }
            }).toList(),
          ],
        ),
      );
    }

    return result.tasks.isEmpty
        ? Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(AppLocalizations.of(context)!.noTasksFound),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                shape: const Border(),
                title: Text(
                  AppLocalizations.of(context)!
                      .foundTasksWithCount(result.tasks.length),
                  style: theme.textTheme.titleMedium,
                ),
                children: [
                  if (searchCriteriaWidget != null) searchCriteriaWidget,
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: result.tasks.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return TaskListCardItemView(
                          task: result.tasks[index],
                          showAssignees: isWebVersion,
                          showMoreOptionsButton: false,
                        );
                      },
                    ),
                  ),
                ],
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
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Only show created fields details for English language
    Widget? fieldsWidget;
    if (isEnglish && result.createdFields.isNotEmpty) {
      fieldsWidget = Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task created with:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            ...result.createdFields.entries.map((entry) {
              if (entry.value is List) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '• ${entry.key}: ${(entry.value as List).join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
            }).toList(),
          ],
        ),
      );
    }

    return isWebVersion ||
            ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!
                  .createdNewTask(result.task.name)),
              if (fieldsWidget != null) fieldsWidget,
              TaskListCardItemView(task: result.task),
            ],
          )
        : Text(AppLocalizations.of(context)!
            .createdNewTaskAndOpenedTaskPage(result.task.name));
  }
}

class UpdateTaskFieldsResultWidget extends ConsumerWidget {
  final UpdateTaskFieldsResultModel result;
  const UpdateTaskFieldsResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Only show changed fields details for English language
    Widget? changesWidget;
    if (isEnglish && result.changedFields.isNotEmpty) {
      changesWidget = Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Updated fields:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            ...result.changedFields.entries.map((entry) {
              final oldValue = entry.value['old'];
              final newValue = entry.value['new'];

              String oldDisplayValue = oldValue == null
                  ? 'not set'
                  : oldValue is List
                      ? oldValue.join(', ')
                      : oldValue.toString();

              String newDisplayValue = newValue == null
                  ? 'not set'
                  : newValue is List
                      ? newValue.join(', ')
                      : newValue.toString();

              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: '• ${entry.key}: '),
                      TextSpan(
                        text: oldDisplayValue,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                      const TextSpan(text: ' → '),
                      TextSpan(
                        text: newDisplayValue,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    }

    return isWebVersion ||
            ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.updatedTask(result.task.name)),
              if (changesWidget != null) changesWidget,
              TaskListCardItemView(task: result.task),
            ],
          )
        : Text(AppLocalizations.of(context)!
            .updatedTaskAndShowedResultInUI(result.task.name));
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
