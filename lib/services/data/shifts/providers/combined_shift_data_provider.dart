import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';

import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_overrides_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_time_ranges_providers.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_timeframes_provider.dart';

class CombinedShiftData {
  final List<ShiftTimeframeModel>? timeframes;
  final List<ShiftLogModel>? logs;
  final List<ShiftOverrideModel>? overrides;
  final List<DateTimeRange> ranges;

  const CombinedShiftData({
    required this.timeframes,
    required this.logs,
    required this.overrides,
    required this.ranges,
  });
}

final combinedShiftDataProvider = Provider.autoDispose
    .family<AsyncValue<CombinedShiftData>, (String, DateTime)>((ref, params) {
  final (shiftId, day) = params;
  
  final timeframes = ref.watch(shiftTimeframesProvider(shiftId));
  final logs = ref.watch(curUserShiftLogsProvider((shiftId: shiftId, day: day)));
  final overrides = ref.watch(curUserShiftOverridesProvider((shiftId: shiftId, day: day)));
  final ranges = ref.watch(curUserShiftTimeRangesProvider((shiftId: shiftId, day: day)));

  // If any are loading, return loading
  if (timeframes.isLoading || logs.isLoading || overrides.isLoading || ranges.isLoading) {
    return const AsyncLoading();
  }

  // If any have errors, return the first error
  if (timeframes.hasError || logs.hasError || overrides.hasError || ranges.hasError) {
    return AsyncError(
      timeframes.error ?? logs.error ?? overrides.error ?? ranges.error ?? 'Unknown error',
      StackTrace.current,
    );
  }

  // All data is available
  return AsyncData(CombinedShiftData(
    timeframes: timeframes.value,
    logs: logs.value,
    overrides: overrides.value,
    ranges: ranges.value ?? [],
  ));
});