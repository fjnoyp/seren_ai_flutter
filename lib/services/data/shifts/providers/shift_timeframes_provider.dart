import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_timeframes_repository.dart';

final shiftTimeframesProvider = StreamProvider.autoDispose
    .family<List<ShiftTimeframeModel>, String>((ref, shiftId) {
  return ref.watch(shiftTimeframesRepositoryProvider).watchTimeframesForShift(shiftId);
});
