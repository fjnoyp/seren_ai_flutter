import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shifts_listener_day_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/debug_shifts_full_day_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

class ShiftsPage extends ConsumerStatefulWidget {
  const ShiftsPage({super.key});

  @override
  ConsumerState<ShiftsPage> createState() => _ShiftsPageState();
}

class _ShiftsPageState extends ConsumerState<ShiftsPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2010),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: {
            CalendarFormat.week: 'Week',
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
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
          child: DayShiftsWidget(day: _selectedDay),
        ),
      ],
    );
  }
}

class DayShiftsWidget extends ConsumerWidget {
  final DateTime day;

  const DayShiftsWidget({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Text(shift.shift.name),
            SizedBox(height: 10),
            Expanded(
              child: debugShiftsFullDayView(day, shift),
            ),
          ],
        );
        /*
            SizedBox(height: 20),
            Text('Shift Logs'),
            Expanded(
              child: ListView.builder(
                itemCount: shift.logs.length,
                itemBuilder: (context, index) {
                  final log = shift.logs[index];
                  return ListTile(
                    title: Text(
                        '${log.clockInDatetime.toLocal().toString()} - ${log.clockOutDatetime?.toLocal().toString() ?? 'Ongoing'}'),
                    subtitle: Text(log.isBreak ? 'Break' : 'Work'),
                  );
                },
              ),
            ),
            */
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
