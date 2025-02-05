import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class TaskListItemView extends ConsumerWidget {
  final TaskModel task;
  const TaskListItemView({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dueDateColor = getDueDateColor(task.dueDate);
    final taskProject =
        ref.watch(projectByIdStreamProvider(task.parentProjectId));
    final taskAssignees = ref.watch(taskAssignedUsersStreamProvider(task.id));

    return GestureDetector(
      onTap: () async {
        await ref
            .read(taskNavigationServiceProvider)
            .openTask(initialTaskId: task.id);
      },
      child: Card(
        color: theme.cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 12.0, 4.0, 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      task.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isWebVersion)
                    Text(
                      taskProject.when(
                          loading: () => '...',
                          error: (err, stack) => 'Error: $err',
                          data: (project) => project!.name),
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(180)),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: (taskAssignees.valueOrNull ?? [])
                          .map((e) => CircleAvatar(
                                radius: 8,
                                child: Text(
                                  e.firstName.substring(0, 1),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                    TaskPriorityView(
                        priority: task.priority ?? PriorityEnum.normal),
                    const SizedBox(height: 4),
                    if (task.dueDate != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: dueDateColor),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.dueDateWithDate(task
                                        .dueDate !=
                                    null
                                ? DateFormat.MMMd(AppLocalizations.of(context)!
                                        .localeName)
                                    .format(task.dueDate!.toLocal())
                                : AppLocalizations.of(context)!.notAvailable),
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: dueDateColor,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 5),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Text(
                        task.description!,
                        maxLines: 3,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskListTileItemView extends ConsumerWidget {
  const TaskListTileItemView(this.task, {super.key});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateColor = getDueDateColor(task.dueDate);
    final taskAssignees = ref.watch(taskAssignedUsersStreamProvider(task.id));

    return ListTile(
      dense: true,
      onTap: () => ref
          .read(taskNavigationServiceProvider)
          .openTask(initialTaskId: task.id),
      leading: const SizedBox.shrink(),
      title: Text(task.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...(taskAssignees.valueOrNull ?? [])
              .map((e) => UserAvatar(e, radius: 8)),
          if (task.priority != null) ...[
            const SizedBox(width: 8),
            TaskPriorityView(priority: task.priority!),
          ],
          if (task.dueDate != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.calendar_today, size: 16, color: dueDateColor),
            const SizedBox(width: 4),
            Text(
              DateFormat.MMMd().format(task.dueDate!.toLocal()),
              style: TextStyle(color: dueDateColor),
            ),
          ],
        ],
      ),
    );
  }
}
