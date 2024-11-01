import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_joined_shifts_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class ClockInOutCard extends StatelessWidget {
  const ClockInOutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomeCard(
      title: AppLocalizations.of(context)!.clockInOut,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            // TODO: refactor to use handable error states
            final joinedShifts = ref.watch(curUserJoinedShiftsListenerProvider);
            final curShift = joinedShifts?.first;
            return switch (joinedShifts) {
              null => const CircularProgressIndicator(),
              [] => Text(AppLocalizations.of(context)!.noShifts),
              List() => _ClockInOutInnerCard(curShift: curShift!),
            };
          },
        ),
      ),
    );
  }
}

class _ClockInOutInnerCard extends ConsumerWidget {
  const _ClockInOutInnerCard({required this.curShift});

  final JoinedShiftModel curShift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curLog = ref.watch(curUserCurShiftLogFamProvider(curShift.shift.id));
    final notifier =
        ref.read(curUserCurShiftLogNotifierProvider(curShift.shift.id));
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    curLog == null ? notifier.clockIn() : notifier.clockOut();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(curLog == null 
                      ? AppLocalizations.of(context)!.startShift 
                      : AppLocalizations.of(context)!.endShift),
                ),
              ],
            ),
            // TODO: add elapsed time ?
            if (curLog != null)
              Text(
                AppLocalizations.of(context)!.clockedInAt(
                  DateFormat.Hm().format(curLog.clockInDatetime)
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
          ],
        ),
      ),
    );
  }
}
