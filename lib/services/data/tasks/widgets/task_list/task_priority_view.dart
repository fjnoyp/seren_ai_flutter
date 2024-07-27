import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class TaskPriorityView extends StatelessWidget {
  final PriorityEnum priority;

  const TaskPriorityView({Key? key, required this.priority}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    switch (priority) {
      case PriorityEnum.veryHigh:
        color = Colors.red;
        break;
      case PriorityEnum.high:
        color = Colors.orange;
        break;
      case PriorityEnum.normal:
        color = Colors.blue;
        break;
      case PriorityEnum.low:
        color = Colors.grey;
        break;
      case PriorityEnum.veryLow:
        color = Colors.lightBlue;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2), // Added padding
      child: Row(
        children: [
          Icon(Icons.flag, color: color, size: 16),
          Text('${priority.toString().split('.').last}',
              style: theme.textTheme.labelSmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}