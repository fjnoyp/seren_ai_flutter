import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';

class TaskPriorityView extends StatelessWidget {
  final PriorityEnum priority;

  const TaskPriorityView({Key? key, required this.priority}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getTaskPriorityColor(priority);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Colors.transparent),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2), // Added padding
      child: Row(
        children: [
          Icon(Icons.priority_high, color: color, size: 16),
          Text('${priority.toString().split('.').last}',
              style: theme.textTheme.labelSmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}