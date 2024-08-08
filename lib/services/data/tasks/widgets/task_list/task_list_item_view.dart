import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_priority_view.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';
class TaskListItemView extends StatelessWidget {
  final JoinedTaskModel joinedTask;
  final DateFormat listDateFormat = DateFormat('MMM dd');

  TaskListItemView({Key? key, required this.joinedTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final task = joinedTask.task;
    final authorUser = joinedTask.authorUser;
    final team = joinedTask.team;
    final project = joinedTask.project;

    final dueDateColor = getDueDateColor(task.dueDate);

    return GestureDetector(
      onTap: () {
        openTaskPage(context, mode: TaskPageMode.readOnly, joinedTask: joinedTask);
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
                  Flexible(
                    child: Text(
                      task.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${project?.name}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TaskPriorityView(
                            priority: task.priorityEnum ?? PriorityEnum.normal),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (task.dueDate != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: dueDateColor),
                          const SizedBox(width: 4),
                          Text(
                            'Due Date: ${task.dueDate?.toIso8601String() != null ? listDateFormat.format(task.dueDate!) : 'N/A'}',
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
