import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/base_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_queries.dart';

final shiftOverridesRepositoryProvider = Provider<ShiftOverridesRepository>((ref) {
  return ShiftOverridesRepository(ref.watch(dbProvider));
});

class ShiftOverridesRepository extends BaseRepository<ShiftOverrideModel> {
  const ShiftOverridesRepository(super.db);

  @override
  Set<String> get watchTables => {'shift_overrides'};

  @override
  ShiftOverrideModel fromJson(Map<String, dynamic> json) {
    return ShiftOverrideModel.fromJson(json);
  }

  Stream<List<ShiftOverrideModel>> watchOverridesForDay({
    required String shiftId,
    required String? userId,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);

    return watch(ShiftQueries.getUserShiftOverridesForDay, {
      'shift_id': shiftId,
      'user_id': userId,
      'day_start': dayStart.toIso8601String(),
    });
  }

  Future<List<ShiftOverrideModel>> getOverridesForDay({
    required String shiftId,
    required String? userId,
    required DateTime day,
  }) async {
    final dayStart = DateTime(day.year, day.month, day.day);

    return get(
      ShiftQueries.getUserShiftOverridesForDay,
      {
        'shift_id': shiftId,
        'user_id': userId,
        'day_start': dayStart.toIso8601String(),
      },
    );
  }
}
