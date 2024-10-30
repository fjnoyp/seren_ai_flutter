import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/utils/duration_extension.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_active_shift_ranges_fam_provider.dart';

import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_joined_shifts_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_joined_shift_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_logs_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/debug_shifts_full_day_view.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dart:async'; // Add this import

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final listDateFormat = DateFormat.jm();

class ShiftsPage extends HookConsumerWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState(DateTime.now().toUtc());
    final focusedDay = useState(DateTime.now().toUtc());

    final joinedShiftState = ref.watch(curUserJoinedShiftProvider);

    if(joinedShiftState is CurUserJoinedShiftLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    JoinedShiftModel? curJoinedShift; 
    if(joinedShiftState is CurUserJoinedShiftLoaded) {
      curJoinedShift = joinedShiftState.joinedShift;
    }

    if(curJoinedShift == null) {
      return const Center(child: Text('No active shift'));
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        TableCalendar(
          locale: AppLocalizations.of(context)!.localeName,
          firstDay: DateTime(2010),
          lastDay: DateTime(2030),
          focusedDay: focusedDay.value,
          selectedDayPredicate: (day) => isSameDay(selectedDay.value, day),
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {
            CalendarFormat.week: 'Week',
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: (newSelectedDay, newFocusedDay) {
            selectedDay.value = newSelectedDay;
            focusedDay.value = newFocusedDay;
          },
          onPageChanged: (newFocusedDay) {
            focusedDay.value = newFocusedDay;
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    width: 6,
                    height: 6,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        Expanded(
          child: _DayShiftsWidget(day: selectedDay.value, shift: curJoinedShift),
        ),
      ],
    );
  }
}

class _DayShiftsWidget extends HookConsumerWidget {
  final DateTime day;
  final JoinedShiftModel shift;

  const _DayShiftsWidget({required this.shift, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = useState(false);

    final theme = Theme.of(context);

    final shiftId = shift.shift.id;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                  icon: Icon(
                    isDebugMode.value ? Icons.list : Icons.bug_report,
                    size: 20, // Smaller size
                  ),
                  onPressed: () {
                    isDebugMode.value = !isDebugMode.value; // Toggle value
                  },
                ),
              ]),
              isDebugMode.value
                  ? debugShiftsFullDayView(shiftId, day)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(shift.shift.name,
                              style: theme.textTheme.titleLarge),
                        ),
                        //const SizedBox(height: 10),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.punch_clock_outlined),
                              const SizedBox(width: 10),
                              _ShiftTimeRangesList(shift.shift.id, day),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_outlined),
                              const SizedBox(width: 10),
                              Text(shift.parentProject?.address ??
                                  AppLocalizations.of(context)!.noProjectAddress),
                            ],
                          ),
                        ),
                        const Divider(),
                        //   _buildShiftTimeRangesList(shiftId, day),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.shiftLogs,
                                style: theme.textTheme.titleMedium,
                              ),
                              _ShiftLogs(shiftId, day),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Positioned(
            bottom: 36.0, child: _ClockInClockOut(shiftId: shiftId, day: day)),
      ],
    );
  }
}

class _ShiftLogs extends ConsumerWidget {
  const _ShiftLogs(this.shiftId, this.day);

  final String shiftId;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftLogs = ref.watch(
        curUserShiftLogsFamListenerProvider((shiftId: shiftId, day: day)));

    if (shiftLogs == null || shiftLogs.isEmpty) {
      return Text(AppLocalizations.of(context)!.noShiftLogs);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shiftLogs.length,
      itemBuilder: (context, index) {
        final log = shiftLogs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '${listDateFormat.format(log.clockInDatetime.toLocal())} - ${log.clockOutDatetime != null ? listDateFormat.format(log.clockOutDatetime!.toLocal()) : AppLocalizations.of(context)!.ongoing}',
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}

class _ShiftTimeRangesList extends ConsumerWidget {
  final String shiftId;
  final DateTime day;

  const _ShiftTimeRangesList(this.shiftId, this.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftTimeRanges = ref.watch(
        curUserActiveShiftRangesFamProvider((shiftId: shiftId, day: day)));

    if (shiftTimeRanges.isEmpty) {
      return Text(AppLocalizations.of(context)!.noShifts);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: shiftTimeRanges.map((timeframe) {
        return Text(
          '${listDateFormat.format(timeframe.start.toLocal())} - ${listDateFormat.format(timeframe.end.toLocal())} - ${timeframe.duration.formatDuration(context)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      }).toList(),
    );
  }
}

class _ClockInClockOut extends HookConsumerWidget {
  final String shiftId;
  final DateTime day;

  const _ClockInClockOut({required this.shiftId, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDateTime = DateTime.now().toUtc();
    Timer? timer; // Declare a Timer variable
    final elapsedTime =
        useState<Duration>(Duration.zero); // State to hold elapsed time

    // if same day, show clock in/out
    if (day.day == curDateTime.day &&
        day.month == curDateTime.month &&
        day.year == curDateTime.year) {
      final curLog = ref.watch(curUserCurShiftLogFamProvider(shiftId));
      final notifier = ref.read(curUserCurShiftLogNotifierProvider(shiftId));

      // Start timer if curLog is not null and clocked in
      useEffect(() {
        if (curLog != null && curLog.clockOutDatetime == null) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            elapsedTime.value =
                DateTime.now().toUtc().difference(curLog.clockInDatetime);
          });
        } else {
          timer?.cancel(); // Cancel timer if not clocked in
        }

        return () => timer?.cancel(); // Dispose timer on widget unmount
      }, [curLog]);

      if (curLog == null) {
        return OutlinedButton(
          onPressed: () => notifier.clockIn(),
          child: Text(AppLocalizations.of(context)!.clockIn),
        );
      } else if (curLog.clockOutDatetime == null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => notifier.clockOut(),
              child: Text(AppLocalizations.of(context)!.clockOut),
            ),
            Text(AppLocalizations.of(context)!.elapsedTime(
              elapsedTime.value.inHours.toString(),
              (elapsedTime.value.inMinutes % 60).toString().padLeft(2, '0'),
              (elapsedTime.value.inSeconds % 60).toString().padLeft(2, '0')
            )),
          ],
        );
      } else {
        timer?.cancel(); // Cancel timer when shift is completed
        return Text(AppLocalizations.of(context)!.shiftCompleted);
      }
    }
    return const SizedBox.shrink(); // Return an empty widget if not the same day
  }
}
