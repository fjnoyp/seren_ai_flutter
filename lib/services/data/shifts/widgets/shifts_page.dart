import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shifts_listener_day_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/debug_shifts_full_day_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

class ShiftsPage extends HookConsumerWidget {
  const ShiftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState(DateTime.now());
    final focusedDay = useState(DateTime.now());

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
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
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
          child: DayShiftsWidget(day: selectedDay.value),
        ),
      ],
    );
  }
}

class DayShiftsWidget extends HookConsumerWidget {
  final DateTime day;

  const DayShiftsWidget({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = useState(false);
    final joinedShifts = ref.watch(curUserShiftsListenerDayFamProvider(day));

    return joinedShifts.when(
      data: (shifts) {
        if (shifts.isEmpty) {
          return const Center(child: Text('No shifts for this day'));
        }

        // TODO p2: Handle multiple shifts in the future
        final shift = shifts.first;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(shift.shift.name),
                SizedBox(width: 10),
                Switch(
                  value: isDebugMode.value,
                  onChanged: (value) {
                    isDebugMode.value = value;
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: isDebugMode.value
                ? debugShiftsFullDayView(day, shift)
                : Column(
                    children: [
                      Text('TODO: Implement non-debug view'),
                    ],
                  ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
