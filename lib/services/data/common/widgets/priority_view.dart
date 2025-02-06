import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class PriorityView extends StatelessWidget {
  final PriorityEnum priority;
  final bool outline;

  const PriorityView({
    super.key,
    required this.priority,
    this.outline = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getTaskPriorityColor(priority);

    return Container(
      decoration: BoxDecoration(
        border: outline ? Border.all(color: color ?? Colors.transparent) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: outline ? const EdgeInsets.all(2) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, color: color, size: 16),
          Flexible(
            child: Text(
              priority.toHumanReadable(context),
              style: theme.textTheme.labelSmall!.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
  }
}
