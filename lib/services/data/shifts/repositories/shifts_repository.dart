import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_queries.dart';

final shiftsRepositoryProvider = Provider<ShiftsRepository>((ref) {
  return ShiftsRepository(ref.watch(dbProvider));
});

class ShiftsRepository extends BaseRepository<JoinedShiftModel> {
  const ShiftsRepository(super.db);

  @override
  Set<String> get watchTables => {'shifts', 'projects'};

  @override
  JoinedShiftModel fromJson(Map<String, dynamic> json) {
    return JoinedShiftModel.fromJson(json);
  }

  Stream<List<JoinedShiftModel>> watchUserShifts({
    required String userId,
    required String orgId,
  }) {
    return watch(
      ShiftQueries.getUserShifts,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    );
  }

  Future<List<JoinedShiftModel>> getUserShifts({
    required String userId,
    required String orgId,
  }) async {
    return get(
      ShiftQueries.getUserShifts,
      {
        'user_id': userId,
        'org_id': orgId,
      },
    );
  }
}
