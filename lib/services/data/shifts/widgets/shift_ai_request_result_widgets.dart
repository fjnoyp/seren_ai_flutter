// Display the results of an ai request

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_tool_methods.dart';

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
          result.clockedIn ? Icons.login : Icons.logout,
          color: theme.colorScheme.onPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            result.resultForAi,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
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
        Text(result.resultForAi),
        const SizedBox(height: 8),
        ...result.shiftLogs.entries.map((entry) {
          final date = entry.key;
          final logs = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  date.toLocal().toString().split(' ')[0],
                  style: theme.textTheme.titleSmall,
                ),
              ),
              ...logs.map((log) {
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
        Text(result.resultForAi),
        const SizedBox(height: 8),
        ...result.shiftAssignments.entries.map((entry) {
          final date = entry.key;
          final ranges = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  date.toLocal().toString().split(' ')[0],
                  style: theme.textTheme.titleSmall,
                ),
              ),
              ...ranges.map((range) {
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
        }),
      ],
    );
  }
}