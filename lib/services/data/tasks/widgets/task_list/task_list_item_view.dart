import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/generate_color_from_id.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/status_view.dart';

class TaskListItemView extends ConsumerWidget {
  const TaskListItemView({
    required this.task,
    super.key,
    this.onTap,
    this.showStatus = false,
    this.showProject = false,
  });

  final TaskModel task;
  final bool showStatus;
  final bool showProject;
  final void Function(String taskId)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dueDateColor =
        task.dueDate != null && task.dueDate!.isBefore(DateTime.now())
            ? Colors.red
            : Colors.grey;

    final taskAssignees = ref.watch(taskAssignedUsersStreamProvider(task.id));

    return ListTile(
      contentPadding: showStatus
          ? null // Use default padding when showing status
          : const EdgeInsets.only(
              right: 16), // Remove left padding when not showing status
      leading: showStatus
          ? Icon(
              getStatusIcon(task.status ?? StatusEnum.open),
              color: getStatusColor(task.status ?? StatusEnum.open),
              size: 24,
            )
          : null, // Set to null instead of SizedBox.shrink()
      title: Text(
        task.name,
        style: theme.textTheme.titleMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProjectIndicator(task, showProject: showProject),
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
                Icon(Icons.calendar_today, size: 14, color: dueDateColor),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().format(task.dueDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dueDateColor,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...(taskAssignees.valueOrNull ?? []).map((e) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: UserAvatar(e, radius: 14),
              )),
        ],
      ),
      onTap: onTap != null
          ? () => onTap!(task.id)
          : () => ref
              .read(taskNavigationServiceProvider)
              .openTask(initialTaskId: task.id),
    );
  }
}

class _ProjectIndicator extends ConsumerWidget {
  const _ProjectIndicator(this.task, {required this.showProject});

  final TaskModel task;
  final bool showProject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        if (!showProject) return const SizedBox.shrink();

        final taskProject =
            ref.watch(projectByIdStreamProvider(task.parentProjectId));
        if (taskProject.valueOrNull == null) return const SizedBox.shrink();

        return Text(
          taskProject.valueOrNull!.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: generateColorFromId(task.parentProjectId),
                fontSize: 11,
              ),
        );
      },
    );
  }
}
