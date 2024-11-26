// Display the results of an ai request

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/common/utils/date_time_range_extension.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Row(
      children: [
        Icon(
          result.clockedIn ? Icons.login : Icons.logout,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            result.clockedIn ? AppLocalizations.of(context)!.successClockIn : AppLocalizations.of(context)!.successClockOut,
            style: Theme.of(context).textTheme.titleMedium,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context)!.requestedShiftLogs,
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.totalHours(
              (result.totalLogMinutes ~/ 60).toString(),
              (result.totalLogMinutes % 60).toString()),
          style: theme.textTheme.bodyMedium,
        ),
        if (result.curShiftMinutes != null)
          Text(
            AppLocalizations.of(context)!.currentShiftDuration(
                (result.curShiftMinutes! ~/ 60).toString(),
                (result.curShiftMinutes! % 60).toString()),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        const SizedBox(height: 8),
        ...result.shiftLogs.entries.map((entry) {
          final date = entry.key;
          final logs = entry.value;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    date.toLocal().getReadableDayOnly(context),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (logs.isNotEmpty)
                    ...logs.map((log) {
                      final isOngoing = log.clockOutDatetime == null;
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              isOngoing ? Icons.timer : Icons.check_circle,
                              size: 16,
                              color: isOngoing
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isOngoing
                                    ? '${DateFormat.Hm().format(log.clockInDatetime.toLocal())} - ONGOING'
                                    : '${DateFormat.Hm().format(log.clockInDatetime.toLocal())} - ${DateFormat.Hm().format(log.clockOutDatetime!.toLocal())}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (logs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(AppLocalizations.of(context)!.noLogs),
                    ),
                ],
              ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context)!.requestedShiftAssignments,
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.totalAssignedHours(
              (result.totalShiftMinutes ~/ 60).toString(),
              (result.totalShiftMinutes % 60).toString()),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ...result.shiftAssignments.entries.map((entry) {
          final date = entry.key;
          final ranges = entry.value;

          return Padding(
            padding: const EdgeInsets.all(0.0), // Added padding to the column
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  //margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Display
                        Text(
                          date.toLocal().getReadableDayOnly(context),
                          style: theme.textTheme.titleSmall,
                        ),
                        // Range(s) Display
                        if (ranges.isNotEmpty)
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
                                        range.toLocal().getReadableTimeOnly()),
                                  ),
                                ],
                              ),
                            );
                          }),
                        if (ranges.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(AppLocalizations.of(context)!.noAssignments),
                          ),
                      ],
                    ),
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
