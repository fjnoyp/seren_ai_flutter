import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/task_list_item_more_options_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/status_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_assignees_avatars.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_project_indicator.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_phase_indicator.dart';

// Card like view that uses ListTile
class TaskListCardItemView extends ConsumerWidget {
  const TaskListCardItemView({
    required this.task,
    super.key,
    this.onTap,
    this.showStatus = false,
    this.showProject = false,
    this.showAssignees = true,
    this.showMoreOptionsButton = true,
  });

  final TaskModel task;
  final bool showStatus;
  final bool showProject;
  final bool showAssignees;
  final bool showMoreOptionsButton;
  final void Function(String taskId)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dueDateColor =
        task.dueDate != null && task.dueDate!.isBefore(DateTime.now())
            ? Colors.red
            : Colors.grey;

    return InkWell(
      onTap: onTap != null
          ? () => onTap!(task.id)
          : () => ref
              .read(taskNavigationServiceProvider)
              .openTask(initialTaskId: task.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            if (showStatus) ...[
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  getStatusIcon(task.status ?? StatusEnum.open),
                  color: getStatusColor(task.status ?? StatusEnum.open),
                  size: 24,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  task.id == ref.watch(curInlineCreatingTaskIdProvider)
                      ? InlineTaskNameField(
                          taskId: task.id,
                          isPhase: task.isPhase,
                          initialStatus: task.status,
                          initialParentTaskId: task.parentTaskId,
                        )
                      : Text(
                          task.name,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                  if (showProject) TaskProjectIndicator(task),
                  if (task.description?.isNotEmpty == true)
                    Text(
                      task.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (task.priority != null) ...[
                        PriorityView(priority: task.priority!),
                        const SizedBox(width: 8),
                      ],
                      if (task.dueDate != null) ...[
                        Icon(Icons.calendar_today,
                            size: 14, color: dueDateColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat.yMMMd().format(task.dueDate!),
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: dueDateColor,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TaskListItemPhaseIndicator(task),
                    if (showMoreOptionsButton)
                      TaskListItemMoreOptionsButton(taskId: task.id),
                  ],
                ),
                const SizedBox(height: 8),
                if (task.id != ref.watch(curInlineCreatingTaskIdProvider) &&
                    showAssignees)
                  SizedBox(
                    width: 92,
                    child: TaskAssigneesAvatars(task.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
