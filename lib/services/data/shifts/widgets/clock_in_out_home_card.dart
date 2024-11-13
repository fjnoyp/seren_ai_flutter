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
      color: Theme.of(context).colorScheme.primaryContainer,
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
      data: (curLog) => Card(
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
                      curLog == null
                          ? curUserShiftLogActions.clockIn()
                          : curUserShiftLogActions.clockOut();
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
              // TODO p4: add elapsed time ?
              if (curLog != null)
                Text(
                  AppLocalizations.of(context)!.clockedInAt(
                      DateFormat.Hm().format(curLog.clockInDatetime)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
