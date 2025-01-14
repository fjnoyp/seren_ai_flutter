import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_dependecy_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_overrides_repository.dart';

final curUserShiftOverridesProvider = StreamProvider.autoDispose.family<List<ShiftOverrideModel>, ({DateTime day})>((ref, args) {
  return CurShiftDependencyProvider.watchStream<List<ShiftOverrideModel>>(
    ref: ref,
    builder: (userId, shift) {
      return ref.watch(shiftOverridesRepositoryProvider).watchOverridesForDay(
        shiftId: shift.id,
        userId: userId,
        day: args.day.toUtc(),
      );
    },
  );
});
