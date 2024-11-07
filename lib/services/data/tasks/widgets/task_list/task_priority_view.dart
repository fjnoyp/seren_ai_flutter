import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class TaskPriorityView extends StatelessWidget {
  final PriorityEnum priority;

  const TaskPriorityView({super.key, required this.priority});

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
          Text(priority.toString().split('.').last,
              style: theme.textTheme.labelSmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}

MaterialColor? getTaskPriorityColor(PriorityEnum priority) {
  switch (priority) {
    case PriorityEnum.veryHigh:
      return Colors.red;
    case PriorityEnum.high:
      return Colors.orange;
    case PriorityEnum.normal:
      return Colors.blue;
    case PriorityEnum.low:
      return Colors.grey;
    case PriorityEnum.veryLow:
      return Colors.lightBlue;
    default:
      return null;
  }
}