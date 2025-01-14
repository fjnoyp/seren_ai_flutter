import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_queries.dart';

final shiftTimeRangesRepositoryProvider =
    Provider<ShiftTimeRangesRepository>((ref) {
  return ShiftTimeRangesRepository(ref.watch(dbProvider));
});

/// Get active shift ranges (timeframes and overrides) for a given day
class ShiftTimeRangesRepository extends BaseRepository<ShiftTimeframeModel> {
  const ShiftTimeRangesRepository(super.db,
      {super.primaryTable = 'shift_timeframes'});

  @override
  ShiftTimeframeModel fromJson(Map<String, dynamic> json) {
    return ShiftTimeframeModel.fromJson(json);
  }

  Stream<List<DateTimeRange>> watchActiveRanges({
    required String shiftId,
    required String userId,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);

    final timeframes = watch(
      ShiftQueries.getActiveShiftRanges,
      {
        'day_start': dayStart.toIso8601String(),
        'shift_id': shiftId,
        'day_of_week': day.weekday,
        'user_id': userId,
      },
      triggerOnTables: {'shift_timeframes', 'shift_overrides'},
    );

    return timeframes.map((results) => results
        .map((tf) => DateTimeRange(
              start: DateTime.parse(tf.startTime),
              end: DateTime.parse(tf.startTime).add(tf.duration),
            ))
        .toList());
  }

  Future<List<DateTimeRange>> getActiveRanges({
    required String shiftId,
    required String userId,
    required DateTime day,
  }) async {
    final dayStart = DateTime(day.year, day.month, day.day);

    final timeframes = await get(
      ShiftQueries.getActiveShiftRanges,
      {
        'day_start': dayStart.toIso8601String(),
        'shift_id': shiftId,
        'day_of_week': day.weekday,
        'user_id': userId,
      },
    );

    return timeframes
        .map((tf) => DateTimeRange(
              start: DateTime.parse(tf.startTime),
              end: DateTime.parse(tf.startTime).add(tf.duration),
            ))
        .toList();
  }
}
