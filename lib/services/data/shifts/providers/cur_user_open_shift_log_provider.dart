import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';

final curUserOpenShiftLogProvider = StreamProvider.autoDispose.family<ShiftLogModel?, String>((ref, shiftId) {
  return CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref.watch(shiftLogsRepositoryProvider).watchCurrentOpenLog(
      shiftId: shiftId,
      userId: userId,
    ),
  );
});
