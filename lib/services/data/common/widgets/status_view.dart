import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';

class StatusView extends StatelessWidget {
  final StatusEnum status;
  final bool outline;

  const StatusView({super.key, required this.status, this.outline = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = getTaskStatusColor(status);

    return Container(
      decoration: outline
          ? BoxDecoration(
              border: Border.all(color: color ?? Colors.transparent),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      padding: outline ? const EdgeInsets.all(2) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getTaskStatusIcon(status), color: color, size: 16),
          Flexible(
            child: Text(
              status.toHumanReadable(context),
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
