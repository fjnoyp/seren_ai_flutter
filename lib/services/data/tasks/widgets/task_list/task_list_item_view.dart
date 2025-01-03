import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class TaskListItemView extends ConsumerWidget {
  final JoinedTaskModel joinedTask;
  const TaskListItemView({super.key, required this.joinedTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final task = joinedTask.task;
    final project = joinedTask.project;

    final dueDateColor = getDueDateColor(task.dueDate);

    return GestureDetector(
      onTap: () async {
        await openTaskPage(context, ref,
            mode: EditablePageMode.readOnly, initialJoinedTask: joinedTask);
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
              // TASK NAME + PROJECT NAME

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TASK NAME
                  Flexible(
                    child: Text(
                      task.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // PROJECT NAME
                  if (!isWebVersion)
                    Text(
                      '${project?.name}',
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
                    if (joinedTask.assignees.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...joinedTask.assignees.map((e) => CircleAvatar(
                                radius: 8,
                                child: Text(
                                  e.firstName.substring(0, 1),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              )),
                        ],
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
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 5),

                    //Text('Author: ${authorUser?.email}'),
                    // if (task.assignedUserId != null) Text('Assigned to: ${task.assignedUserId}'),
                    //Text('Team: ${team?.name}'),
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
  const TaskListTileItemView(this.joinedTask, {super.key});

  final JoinedTaskModel joinedTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateColor = getDueDateColor(joinedTask.task.dueDate);

    return ListTile(
      dense: true,
      onTap: () => openTaskPage(context, ref,
          mode: EditablePageMode.readOnly, initialJoinedTask: joinedTask),
      leading: const SizedBox.shrink(),
      title: Text(joinedTask.task.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...joinedTask.assignees.map((e) => UserAvatar(e, radius: 8)),
          if (joinedTask.task.priority != null) ...[
            const SizedBox(width: 8),
            TaskPriorityView(priority: joinedTask.task.priority!),
          ],
          if (joinedTask.task.dueDate != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.calendar_today, size: 16, color: dueDateColor),
            const SizedBox(width: 4),
            Text(
              DateFormat.MMMd().format(joinedTask.task.dueDate!.toLocal()),
              style: TextStyle(color: dueDateColor),
            ),
          ],
        ],
      ),
    );
  }
}
