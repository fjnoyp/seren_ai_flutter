import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_priority_view.dart';

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

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 12.0, 4.0, 12.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: theme.textTheme.titleMedium,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5),
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
                            Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Due Date: ${task.dueDate?.toIso8601String() != null ? listDateFormat.format(task.dueDate!) : 'N/A'}',
                              style: theme.textTheme.labelSmall!.copyWith(
                                color: DateTime.now().isAfter(task.dueDate!)
                                    ? Colors.red
                                    : null,
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
                      Text('${project?.name}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
