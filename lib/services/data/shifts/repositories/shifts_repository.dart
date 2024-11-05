import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/base_repository.dart';
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
  }) {
    return watch(
      ShiftQueries.getUserShifts,
      {
        'user_id': userId,
      },
    );
  }

  Future<List<JoinedShiftModel>> getUserShifts({
    required String userId,
  }) async {
    return get(
      ShiftQueries.getUserShifts,
      {
        'user_id': userId,
      },
    );
  }
}
