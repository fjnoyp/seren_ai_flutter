import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';

class TaskStatusView extends StatelessWidget {
  final StatusEnum status;

  const TaskStatusView({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getTaskStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Colors.transparent),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2), // Added padding
      child: Row(
        children: [
          Icon(getTaskStatusIcon(status), color: color, size: 16),
          Text('${status.toString().split('.').last}',
              style: theme.textTheme.labelSmall!.copyWith(color: color)),
        ],
      ),
    );
  }
}

IconData? getTaskStatusIcon(StatusEnum status) {
  switch (status) {
    case StatusEnum.open:
      return Icons.circle_outlined;
    case StatusEnum.inProgress:
      return Icons.play_circle_fill;
    case StatusEnum.finished:
      return Icons.check_circle_outline;
    case StatusEnum.cancelled:
      return Icons.cancel_outlined;
    case StatusEnum.archived:
      return Icons.archive_outlined;
    default:
      return null;
  }
}

MaterialColor? getTaskStatusColor(StatusEnum status) {
  switch (status) {
    case StatusEnum.open:
      return Colors.blue;
    case StatusEnum.inProgress:
      return Colors.green;
    case StatusEnum.finished:
      return Colors.yellow;    
    default:
      return null;
  }
}
