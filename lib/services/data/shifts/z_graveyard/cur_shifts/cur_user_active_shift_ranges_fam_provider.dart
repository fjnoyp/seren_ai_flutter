import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_timeframes_shift_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_logs_fam_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/shift_day_fam_listener_providers/cur_user_shift_overrides_fam_listener_provider.dart';

  // TODO p3: missing multiday shift support + local timezone support

/// Provides shift times for a specific shift and day 
final curUserActiveShiftRangesFamProvider = NotifierProvider.family<CurUserActiveShiftRangesFamNotifier, List<DateTimeRange>, ({String shiftId, DateTime day})>(CurUserActiveShiftRangesFamNotifier.new);

class CurUserActiveShiftRangesFamNotifier extends FamilyNotifier<List<DateTimeRange>, ({String shiftId, DateTime day})> {
  @override
  List<DateTimeRange> build(({String shiftId, DateTime day}) args) {
    final timeframes = ref.watch(curUserShiftTimeframesFamListenerProvider(args.shiftId));
    final overrides = ref.watch(curUserShiftOverridesFamListenerProvider((shiftId: args.shiftId, day: args.day)));

    return _getShiftTimeRangesForDay(args.day, timeframes ?? [], overrides ?? []);
  }

  List<DateTimeRange> _getShiftTimeRangesForDay(DateTime day, List<ShiftTimeframeModel> timeFrames, List<ShiftOverrideModel> overrides) {
    final dayOfWeek = day.weekday;

    List<ShiftTimeframeModel> dayTimeframes = timeFrames.where((tf) => 
      tf.dayOfWeek == dayOfWeek
    ).toList();

    List<ShiftOverrideModel> dayOverrides = overrides.where((override) =>
      _isSameDay(override.startDateTime, day) ||
      _isSameDay(override.endDateTime, day)
    ).toList();

    List<DateTimeRange> timeframeRanges = dayTimeframes.map((tf) {
      final start = tf.getStartDateTime(day);
      final end = tf.getEndDateTime(day);
      return DateTimeRange(start: start, end: end);
    }).toList();

    List<OverrideDateTimeRange> overrideRanges = dayOverrides.map((override) {
      return OverrideDateTimeRange(
        isOverride: override.isRemoval,
        range: DateTimeRange(start: override.startDateTime, end: override.endDateTime),
      );
    }).toList();

    List<DateTimeRange> finalRanges = [];

    for (var tfRange in timeframeRanges) {
      bool isOverlapped = overrideRanges.any((orRange) => orRange.isOverlapping(tfRange));
      if (!isOverlapped) {
        finalRanges.add(tfRange);
      }
    }

    finalRanges.addAll(overrideRanges.where((orRange) => !orRange.isOverride).map((e) => e.range));

    finalRanges.sort((a, b) => a.start.compareTo(b.start));

    return finalRanges;
  }

  bool _isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
  }
}

class OverrideDateTimeRange {
  final bool isOverride;
  final DateTimeRange range;

  OverrideDateTimeRange({required this.isOverride, required this.range});

  bool isOverlapping(DateTimeRange other) {
    return range.start.isBefore(other.end) && range.end.isAfter(other.start);
  }
}