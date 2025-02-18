import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class TaskListTileItemView extends ConsumerWidget {
  const TaskListTileItemView(this.task, {super.key, this.onTap});

  final TaskModel task;

  /// If this is null, tapping on a task will open the task page
  final void Function(String taskId)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateColor = getDueDateColor(task.dueDate);
    final taskAssignees = ref.watch(taskAssignedUsersStreamProvider(task.id));

    return ListTile(
      dense: true,
      onTap: onTap != null
          ? () => onTap!(task.id)
          : () => ref
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
            PriorityView(priority: task.priority!),
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
