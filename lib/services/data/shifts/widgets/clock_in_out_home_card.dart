import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/open_shift_log_provider.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class ClockInOutHomeCard extends StatelessWidget {
  const ClockInOutHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomeCard(
      title: AppLocalizations.of(context)!.clockInOut,
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final shiftState = ref.watch(curShiftStateProvider);
            return shiftState.when(
              data: (shift) {
                return shift == null
                    ? Text(AppLocalizations.of(context)!.noShifts)
                    : const _ClockInOutInnerCard();
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text(error.toString()),
            );
          },
        ),
      ),
    );
  }
}

class _ClockInOutInnerCard extends ConsumerWidget {
  const _ClockInOutInnerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUserShiftLogActions = ref.read(curUserShiftLogActionsProvider);

    return AsyncValueHandlerWidget<ShiftLogModel?>(
      value: ref.watch(curUserOpenShiftLogProvider),
      data: (curLog) => BaseHomeInnerCard.filled(
        child: InkWell(
          onTap: () {
            curLog == null
                ? curUserShiftLogActions.clockIn()
                : curUserShiftLogActions.clockOut();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(curLog == null
                        ? AppLocalizations.of(context)!.startShift
                        : AppLocalizations.of(context)!.endShift),
                  ],
                ),
                if (curLog != null) ...[
                  const SizedBox(height: 8),
                  // TODO p4: add elapsed time ?
                  Text(
                    AppLocalizations.of(context)!.clockedInAt(DateFormat.Hm()
                        .format(curLog.clockInDatetime.toLocal())),
                    textAlign: TextAlign.center,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
