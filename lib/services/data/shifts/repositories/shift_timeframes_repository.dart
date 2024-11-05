import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/base_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_queries.dart';

final shiftTimeframesRepositoryProvider = Provider<ShiftTimeframesRepository>((ref) {
  return ShiftTimeframesRepository(ref.watch(dbProvider));
});

class ShiftTimeframesRepository extends BaseRepository<ShiftTimeframeModel> {
  const ShiftTimeframesRepository(super.db);

  @override
  Set<String> get watchTables => {'shift_timeframes'};

  @override
  ShiftTimeframeModel fromJson(Map<String, dynamic> json) {
    return ShiftTimeframeModel.fromJson(json);
  }

  Stream<List<ShiftTimeframeModel>> watchTimeframesForShift(String shiftId) {
    return watch(ShiftQueries.getShiftTimeframes, {
      'shift_id': shiftId,
    });
  }

  Future<List<ShiftTimeframeModel>> getTimeframesForShift(String shiftId) async {
    return get(ShiftQueries.getShiftTimeframes, {
      'shift_id': shiftId,
    });
  }
}
