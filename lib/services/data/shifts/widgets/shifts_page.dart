import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/utils/duration_extension.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_active_shift_ranges_fam_provider.dart';

import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_joined_shifts_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shift_log/cur_user_cur_shift_log_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_logs_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/debug_shifts_full_day_view.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dart:async'; // Add this import

final DateFormat listDateFormat = DateFormat('HH:mm');

class ShiftsPage extends HookConsumerWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState(DateTime.now().toUtc());
    final focusedDay = useState(DateTime.now().toUtc());

    // TODO p3: Allow choosing which shift to view
    final joinedShifts = ref.watch(curUserJoinedShiftsListenerProvider);

    if (joinedShifts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (joinedShifts.isEmpty) {
      return const Center(child: Text('No shifts'));
    }

    final selectedShift = joinedShifts[0];

    final theme = Theme.of(context);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2010),
          lastDay: DateTime(2030),
          focusedDay: focusedDay.value,
          selectedDayPredicate: (day) => isSameDay(selectedDay.value, day),
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: {
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
          child: DayShiftsWidget(day: selectedDay.value, shift: selectedShift),
        ),
      ],
    );
  }
}

class DayShiftsWidget extends HookConsumerWidget {
  final DateTime day;
  final JoinedShiftModel shift;

  const DayShiftsWidget({Key? key, required this.shift, required this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = useState(false);

    final theme = Theme.of(context);

    final shiftId = shift.shift.id;

    return Stack(
      alignment: Alignment.bottomCenter,
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
                              _buildShiftTimeRangesList(shift.shift.id, day),
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
                                  'No project address'),
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
                                'Shift Logs',
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
        ClockInClockOut(shiftId: shiftId, day: day),
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
      return const Text('No shift logs');
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
            '${listDateFormat.format(log.clockInDatetime.toLocal())} - ${log.clockOutDatetime != null ? listDateFormat.format(log.clockOutDatetime!.toLocal()) : 'Ongoing'}',
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}

// TODO: don't use functions to build widgets
Widget _buildShiftTimeRangesList(String shiftId, DateTime day) {
  return Consumer(
    builder: (context, ref, child) {
      final shiftTimeRanges = ref.watch(
          curUserActiveShiftRangesFamProvider((shiftId: shiftId, day: day)));

      if (shiftTimeRanges.isEmpty) {
        return Text('No shifts!');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: shiftTimeRanges.map((timeframe) {
          return Text(
            '${listDateFormat.format(timeframe.start.toLocal())} - ${listDateFormat.format(timeframe.end.toLocal())} - ${timeframe.duration.formatDuration()}',
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }).toList(),
      );
    },
  );
}

class ClockInClockOut extends HookConsumerWidget {
  final String shiftId;
  final DateTime day;

  const ClockInClockOut({Key? key, required this.shiftId, required this.day})
      : super(key: key);

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
          timer ??= Timer.periodic(Duration(seconds: 1), (_) {
            elapsedTime.value =
                DateTime.now().toUtc().difference(curLog.clockInDatetime);
          });
        } else {
          timer?.cancel(); // Cancel timer if not clocked in
        }

        return () => timer?.cancel(); // Dispose timer on widget unmount
      }, [curLog]);

      if (curLog == null) {
        return ElevatedButton(
          onPressed: () => notifier.clockIn(),
          child: Text('Clock In'),
        );
      } else if (curLog.clockOutDatetime == null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => notifier.clockOut(),
              child: Text('Clock Out'),
            ),
            Text(
                'Elapsed Time: ${elapsedTime.value.inHours}:${(elapsedTime.value.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsedTime.value.inSeconds % 60).toString().padLeft(2, '0')}'),
          ],
        );
      } else {
        timer?.cancel(); // Cancel timer when shift is completed
        return Text('Shift completed');
      }
    }
    return SizedBox.shrink(); // Return an empty widget if not the same day
  }
}
