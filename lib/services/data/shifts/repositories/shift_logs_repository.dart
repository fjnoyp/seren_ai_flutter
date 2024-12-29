import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_queries.dart';

final shiftLogsRepositoryProvider = Provider<ShiftLogsRepository>((ref) {
  return ShiftLogsRepository(ref.watch(dbProvider));
});

class ShiftLogsRepository extends BaseRepository<ShiftLogModel> {
  const ShiftLogsRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'shift_logs'};

  @override
  ShiftLogModel fromJson(Map<String, dynamic> json) {
    return ShiftLogModel.fromJson(json);
  }

  Stream<ShiftLogModel?> watchCurrentOpenLog({
    required String shiftId,
    required String userId,
  }) {
    return watch(
      ShiftQueries.getCurrentShiftLogs,
      {
        'shift_id': shiftId,
        'user_id': userId,
      },
    ).map((logs) => logs.isEmpty ? null : logs.first);
  }

  Future<ShiftLogModel?> getCurrentOpenLog({
    required String shiftId,
    required String userId,
  }) async {
    final logs = await get(ShiftQueries.getCurrentShiftLogs, {
      'shift_id': shiftId,
      'user_id': userId,
    });
    return logs.isEmpty ? null : logs.first;
  }

  Stream<List<ShiftLogModel>> watchUserShiftLogsForDay({
    required String shiftId,
    required String userId,
    required DateTime day,
  }) {
    return watch(
      ShiftQueries.getUserShiftLogsForDay,
      {
        'shift_id': shiftId,
        'user_id': userId,
        'day_start': day.toIso8601String(),
      },
    );
  }

  Future<List<ShiftLogModel>> getUserShiftLogsForDay({
    required String shiftId,
    required String userId,
    required DateTime day,
  }) async {
    return get(
      ShiftQueries.getUserShiftLogsForDay,
      {
        'shift_id': shiftId,
        'user_id': userId,
        'day_start': day.toIso8601String(),
      },
    );
  }
}
