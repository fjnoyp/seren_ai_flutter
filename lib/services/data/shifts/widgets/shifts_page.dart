import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/utils/duration_extension.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/open_shift_log_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_time_ranges_providers.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/debug_shifts_full_day_view.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final listDateFormat = DateFormat.jm();

class ShiftsPage extends HookConsumerWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState(DateTime.now().toUtc());
    final focusedDay = useState(DateTime.now().toUtc());

    final joinedShiftState = ref.watch(curShiftStateProvider);

    return joinedShiftState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (curJoinedShift) {
        if (curJoinedShift == null) {
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
      },
    );
  }
}

class TestWidget extends ConsumerWidget {
  final DateTime day;

  const TestWidget({super.key, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curAuthUserState = ref.watch(curAuthStateProvider);
    final curUserId = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    if (curUserId == null) {
      return const Text('No user id');
    }

    final activeShiftRanges = ref.watch(curUserShiftTimeRangesProvider((day: day)));
    
    return AsyncValueHandlerWidget<List<DateTimeRange>>(
      value: activeShiftRanges,
      data: (ranges) {
        if (ranges.isEmpty) {
          return const Text('No active shift ranges');
        }
        return Column(
          children: ranges.map((range) {
            return Text('Active Shift Range: ${range.start} - ${range.end}');
          }).toList(),
        );
      },
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
                    size: 20,
                  ),
                  onPressed: () {
                    isDebugMode.value = !isDebugMode.value;
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
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.punch_clock_outlined),
                              const SizedBox(width: 10),
                              _ShiftTimeRangesList(day),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.shiftLogs,
                                style: theme.textTheme.titleMedium,
                              ),
                              _ShiftLogs(day),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Positioned(
            bottom: 36.0, child: _ClockInClockOut(day: day)),
      ],
    );
  }
}

class _ShiftLogs extends ConsumerWidget {
  const _ShiftLogs(this.day);

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftLogsStream = ref.watch(curUserShiftLogsProvider((day: day)));

    return AsyncValueHandlerWidget(
      value: shiftLogsStream,
      data: (logs) {
        if (logs.isEmpty) {
          return const Text('No shift logs');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${listDateFormat.format(log.clockInDatetime.toLocal())} - ${log.clockOutDatetime != null ? listDateFormat.format(log.clockOutDatetime!.toLocal()) : AppLocalizations.of(context)!.ongoing}',
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShiftTimeRangesList extends ConsumerWidget {
  final DateTime day;

  const _ShiftTimeRangesList(this.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftTimeRangesStream = ref.watch(curUserShiftTimeRangesProvider((day: day)));

    return AsyncValueHandlerWidget(
      value: shiftTimeRangesStream,
      data: (timeRanges) {
        if (timeRanges.isEmpty) {
          return const Text('No shifts!');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: timeRanges.map((timeframe) {
            return Text(
              '${listDateFormat.format(timeframe.start.toLocal())} - ${listDateFormat.format(timeframe.end.toLocal())} - ${timeframe.duration.formatDuration(context)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ClockInClockOut extends HookConsumerWidget {
  final DateTime day;

  const _ClockInClockOut({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDateTime = DateTime.now().toUtc();
    Timer? timer;
    final elapsedTime = useState<Duration>(Duration.zero);

    if (day.day == curDateTime.day &&
        day.month == curDateTime.month &&
        day.year == curDateTime.year) {

      final curLogStream = ref.watch(curUserOpenShiftLogProvider);
      final curUserShiftLogActions = ref.watch(curUserShiftLogActionsProvider);

      useEffect(() {
        final curLog = curLogStream.value;
        if (curLog != null && curLog.clockOutDatetime == null) {
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            elapsedTime.value =
                DateTime.now().toUtc().difference(curLog.clockInDatetime);
          });
        }
        return () => timer?.cancel();
      }, [curLogStream.value]);

      return AsyncValueHandlerWidget(
        value: curLogStream,
        data: (curLog) {
          if (curLog == null) {
            return OutlinedButton(
              onPressed: () => curUserShiftLogActions.clockIn(),
              child: const Text('Clock In'),
            );
          } else if (curLog.clockOutDatetime == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => curUserShiftLogActions.clockOut(),
                  child: const Text('Clock Out'),
                ),
                Text(AppLocalizations.of(context)!.elapsedTime(
                  elapsedTime.value.inHours.toString(),
                  (elapsedTime.value.inMinutes % 60).toString().padLeft(2, '0'),
                  (elapsedTime.value.inSeconds % 60).toString().padLeft(2, '0')
                )),
              ],
            );
          } else {
            return Text(AppLocalizations.of(context)!.shiftCompleted);
          }
        },
      );
    }
    return const SizedBox.shrink();
  }
}
