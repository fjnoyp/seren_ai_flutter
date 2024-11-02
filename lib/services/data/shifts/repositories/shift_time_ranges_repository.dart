import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/base_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_queries.dart';

final shiftTimeRangesRepositoryProvider = Provider<ShiftTimeRangesRepository>((ref) {
  return ShiftTimeRangesRepository(ref.watch(dbProvider));
});

/// Get active shift ranges (timeframes and overrides) for a given day
class ShiftTimeRangesRepository extends BaseRepository<DateTimeRange> {
  const ShiftTimeRangesRepository(super.db);

  @override
  Set<String> get watchTables => {
    'shift_timeframes',
    'shift_overrides',
  };

  @override
  DateTimeRange fromJson(Map<String, dynamic> json) {
    return DateTimeRange(
      start: DateTime.parse(json['range_start']),
      end: DateTime.parse(json['range_end']),
    );
  }

  Stream<List<DateTimeRange>> watchActiveRanges({
    required String shiftId,
    required String userId,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    
    return watch(
      ShiftQueries.getActiveShiftRanges,
      {
        'day_start': dayStart.toIso8601String(),
        'shift_id': shiftId,
        'day_of_week': day.weekday,
        'user_id': userId,
      },
    );
  }

  Future<List<DateTimeRange>> getActiveRanges({
    required String shiftId,
    required String userId,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    
    return get(
      ShiftQueries.getActiveShiftRanges,
      {
        'day_start': dayStart.toIso8601String(),
        'shift_id': shiftId,
        'day_of_week': day.weekday,
        'user_id': userId,
      },
    );
  }
}