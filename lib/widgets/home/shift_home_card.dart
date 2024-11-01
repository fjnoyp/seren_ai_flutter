import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_active_shift_ranges_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_joined_shifts_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_joined_shift_provider.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomeCard(
      title: AppLocalizations.of(context)!.todaysShift,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final shiftIdState = ref.watch(curUserJoinedShiftProvider);
            return switch (shiftIdState) {
              CurUserJoinedShiftLoading() => const CircularProgressIndicator(),
              CurUserJoinedShiftLoaded(joinedShift: final joinedShift) => Builder(
                builder: (context) {
                  if (joinedShift == null) {
                    return const Text('No active shift');
                  }
                  
                  final activeShiftRanges = ref.watch(
                    curUserActiveShiftRangesFamProvider((
                      shiftId: joinedShift.shift.id,
                      day: DateTime.now().toUtc()
                    ))
                  );

                  if (activeShiftRanges.isEmpty) {
                    return const Text('No active shift ranges for today in the current shift');
                  }

                  return InkWell(
                    onTap: () => Navigator.of(context).pushNamed(shiftsRoute),
                    child: _ShiftInnerCard(activeShiftRanges),
                  );
                }
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ShiftInnerCard extends ConsumerWidget {
  const _ShiftInnerCard(this.activeShiftRanges);

  final List<DateTimeRange> activeShiftRanges;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
