import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_dependecy_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';

final curUserOpenShiftLogProvider = StreamProvider.autoDispose<ShiftLogModel?>((ref) {
  return CurShiftDependencyProvider.watchStream(
    ref: ref,
    builder: (userId, shift) => ref.watch(shiftLogsRepositoryProvider).watchCurrentOpenLog(
      shiftId: shift.id,
      userId: userId,
    ),
  );
});
