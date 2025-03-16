import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/task_list_item_more_options_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_assignees_avatars.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';

class TaskListItemView extends ConsumerWidget {
  const TaskListItemView(this.task, {super.key, this.onTap});

  final TaskModel task;

  /// If this is null, tapping on a task will open the task page
  final void Function(String taskId)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateColor = getDueDateColor(task.dueDate);

    final isCreatingTask =
        task.id == ref.watch(curInlineCreatingTaskIdProvider);

    return ListTile(
      dense: true,
      onTap: onTap != null
          ? () => onTap!(task.id)
          : () => ref
              .read(taskNavigationServiceProvider)
              .openTask(initialTaskId: task.id),
      //leading: const SizedBox.shrink(),
      title: task.id == ref.watch(curInlineCreatingTaskIdProvider)
          ? InlineTaskNameField(
              taskId: task.id,
              isPhase: task.isPhase,
              initialStatus: task.status,
              initialParentTaskId: task.parentTaskId,
            )
          : Text(
              task.name,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 200;

        if (isNarrow) {
          return TaskListItemMoreOptionsButton(taskId: task.id);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCreatingTask)
              Flexible(
                child: SizedBox(
                  width: 92,
                  child: TaskAssigneesAvatars(task.id),
                ),
              ),
            if (task.priority != null) ...[
              const SizedBox(width: 8),
              PriorityView(priority: task.priority!),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.calendar_today, size: 16, color: dueDateColor),
              const SizedBox(width: 4),
              Text(
                DateFormat.MMMd().format(task.dueDate!),
                style: TextStyle(color: dueDateColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            TaskListItemMoreOptionsButton(taskId: task.id),
          ],
        );
      }),
    );
  }
}
