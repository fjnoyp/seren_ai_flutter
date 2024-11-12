import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/utils/date_time_extension.dart';
import 'package:seren_ai_flutter/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';

import 'package:seren_ai_flutter/services/data/shifts/providers/shift_time_ranges_providers.dart';

import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class ShiftCard extends ConsumerWidget {
  const ShiftCard({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseHomeCard(
      title: AppLocalizations.of(context)!.todaysShift,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: AsyncValueHandlerWidget<List<DateTimeRange>>(
          value: ref.watch(curUserShiftTimeRangesProvider(
            (day: DateTime.now().dateOnlyUTC())
          )),
          data: (ranges) {
            
            if (ranges.isEmpty) {
              return const Text('No active shift ranges for today');
            }

            return InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoute.shifts.name),
              child: _ShiftInnerCard(ranges),
            );
          },          
        ),
      ),
    );
  }
}

class _ShiftInnerCard extends StatelessWidget {
  const _ShiftInnerCard(this.activeShiftRanges);

  final List<DateTimeRange> activeShiftRanges;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.EEEE(AppLocalizations.of(context)!.localeName)
                  .add_MMMd()
                  .format(DateTime.now()),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.timeRange(
                      DateFormat.Hm()
                          .format(activeShiftRanges.first.start.toLocal()),
                      DateFormat.Hm()
                          .format(activeShiftRanges.first.end.toLocal())),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
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
