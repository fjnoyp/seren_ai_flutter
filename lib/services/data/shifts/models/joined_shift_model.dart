import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';
class JoinedShiftModel {
  final ShiftModel shift;
  final List<ShiftTimeframeModel> timeFrames;
  final List<ShiftLogModel> logs;
  final List<ShiftOverrideModel> overrides;

  JoinedShiftModel({
    required this.shift,
    required this.timeFrames,
    required this.logs,
    required this.overrides,
  });

  bool _isSameDay(DateTime day, DateTime otherDay) {
    return day.year == otherDay.year &&
           day.month == otherDay.month &&
           day.day == otherDay.day;
  }

  // ShiftTimeframes are given as startTime and duration
  // We must convert them to start and end DateTime
  DateTime _getShiftTimeframeToRange(ShiftTimeframeModel timeFrame) {

    final dayOfWeek = timeFrame.dayOfWeek;
    final startTime = timeFrame.startTime;     
    final duration = timeFrame.duration;


    //return timeframe.startTime.subtract(Duration(hours: timeframe.durationHours));
    return DateTime.now();
  }

  // Get the actual shifts for the day, taking into account overrides
  List<ShiftTimeframeModel> getShiftsForDay(DateTime day) {
    // Get the original shift timeframes for the given day
    final dayOfWeek = day.weekday;

    // Find the ShitTimeframe whose day matches the given day
    List<ShiftTimeframeModel> dayTimeframes = timeFrames.where((tf) => 
      tf.dayOfWeek == dayOfWeek
    ).toList();

    // Check for overrides on the given day
    List<ShiftOverrideModel> dayOverrides = overrides.where((override) =>
      _isSameDay(override.startDateTime, day) ||
      _isSameDay(override.endDateTime, day)
    ).toList();



    return [];
  }
}
