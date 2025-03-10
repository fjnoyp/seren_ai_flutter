import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';

class TaskListTileItemView extends ConsumerWidget {
  const TaskListTileItemView(this.task, {super.key, this.onTap});

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
      leading: const SizedBox.shrink(),
      title: task.id == ref.watch(curInlineCreatingTaskIdProvider)
          ? InlineTaskNameField(
              taskId: task.id,
              isPhase: task.isPhase,
              initialStatus: task.status,
              initialParentTaskId: task.parentTaskId,
            )
          : Text(task.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCreatingTask)
            SizedBox(
              width: 92,
              child: TaskAssigneesSelectionField(
                taskId: task.id,
                context: context,
                showLabelWidget: false,
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
            ),
          ],
        ],
      ),
    );
  }
}
