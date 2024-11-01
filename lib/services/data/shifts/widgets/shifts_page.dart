import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/utils/duration_extension.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_user_shift_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/open_shift_log_providers.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_time_ranges_providers.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_service.dart';
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

    final joinedShiftState = ref.watch(curUserShiftProvider);

    if(joinedShiftState is CurUserShiftLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if(joinedShiftState is CurUserShiftError) {
      return Center(child: Text(joinedShiftState.errorMessage));
    }

    JoinedShiftModel? curJoinedShift; 
    if(joinedShiftState is CurUserShiftLoaded) {
      curJoinedShift = joinedShiftState.shift;
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

class TestWidget extends ConsumerWidget {
  final DateTime day;
  final JoinedShiftModel shift;

  const TestWidget({super.key, required this.day, required this.shift});

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

    final activeShiftRanges = ref.watch(shiftTimeRangesProvider((shiftId: shift.shift.id, day: day.toUtc(), userId: curUserId.id)));
    return activeShiftRanges.when(
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
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => SelectableText('Error: $error'),
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
    final shiftLogsStream = ref.watch(
        curUserShiftLogsProvider((shiftId: shiftId, day: day)));

    if (shiftLogsStream.hasError) {
      return const Text('Error loading shift logs');
    }

    if (shiftLogsStream.isLoading) {
      return const CircularProgressIndicator();
    }

    if (shiftLogsStream.value == null || shiftLogsStream.value!.isEmpty) {
      return const Text('No shift logs');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shiftLogsStream.value!.length,
      itemBuilder: (context, index) {
        final log = shiftLogsStream.value![index];
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
    final shiftTimeRangesStream = ref.watch(
        curUserShiftTimeRangesProvider((shiftId: shiftId, day: day)));

    if (shiftTimeRangesStream.hasError) { 
      return const Text('Error loading shift time ranges');
    }

    if (shiftTimeRangesStream.isLoading) {
      return const CircularProgressIndicator();
    }

    if (shiftTimeRangesStream.value == null || shiftTimeRangesStream.value!.isEmpty) {
      return const Text('No shifts!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: shiftTimeRangesStream.value!.map((timeframe) {
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

      final curLogStream = ref.watch(curUserOpenShiftLogProvider((shiftId))); 

      if (curLogStream.hasError) {
        return const Text('Error loading shift logs');
      }

      if (curLogStream.isLoading) {
        return const CircularProgressIndicator();
      }

      final shiftLogService = ref.watch(shiftLogServiceProvider); 

      final curLog = curLogStream.value;

      
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
          onPressed: () => shiftLogService.clockIn(shiftId),
          child: const Text('Clock In'),
        );
      } else if (curLog.clockOutDatetime == null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => shiftLogService.clockOut(shiftId),
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
        timer?.cancel(); // Cancel timer when shift is completed
        return Text(AppLocalizations.of(context)!.shiftCompleted);
      }
    }
    return const SizedBox.shrink(); // Return an empty widget if not the same day
  }
}
