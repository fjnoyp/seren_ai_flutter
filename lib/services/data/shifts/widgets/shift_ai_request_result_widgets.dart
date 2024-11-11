// Display the results of an ai request

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/shift_tool_methods.dart';

// class ShiftInfoResultWidget extends ConsumerWidget {
//   final ShiftAssignmentsResultModel result;
//   const ShiftInfoResultWidget({super.key, required this.result});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(result.message),
//         const SizedBox(height: 8),
//         ...result.activeShiftRanges.map((range) {
//           return Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Text(
//               '${range.start.toLocal().toString()} - ${range.end.toLocal().toString()}',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }

class ShiftClockInOutResultWidget extends ConsumerWidget {
  final ShiftClockInOutResultModel result;
  const ShiftClockInOutResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          result.hasError ? Icons.error : (result.clockedIn ? Icons.login : Icons.logout),
          color: result.hasError ? theme.colorScheme.error : theme.colorScheme.onPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            result.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: result.hasError ? theme.colorScheme.error : theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class ShiftLogsResultWidget extends ConsumerWidget {
  final ShiftLogsResultModel result;
  const ShiftLogsResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.message),
        const SizedBox(height: 8),
        ...result.shiftLogs.map((log) {
          final endTime = log.clockOutDatetime?.toLocal().toString() ?? 'ONGOING';
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(
                  log.clockOutDatetime == null ? Icons.timer : Icons.check_circle,
                  size: 16,
                  color: log.clockOutDatetime == null ? theme.colorScheme.primary : theme.colorScheme.onBackground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${log.clockInDatetime.toLocal().toString()} - $endTime',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ShiftAssignmentsResultWidget extends ConsumerWidget {
  final ShiftAssignmentsResultModel result;
  const ShiftAssignmentsResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.message),
        const SizedBox(height: 8),
        ...result.activeShiftRanges.map((range) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${range.start.toLocal().toString()} - ${range.end.toLocal().toString()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}