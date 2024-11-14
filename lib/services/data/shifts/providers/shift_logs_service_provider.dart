import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_dependecy_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_service.dart';

final shiftLogServiceProvider = Provider<ShiftLogService>((ref) {
  return ShiftLogService(ref.read(shiftLogsRepositoryProvider));
});

final curUserShiftLogActionsProvider = Provider<CurUserShiftLogActions>((ref) {
  return CurUserShiftLogActions(ref);
});

class CurUserShiftLogActions {
  final Ref ref;

  CurUserShiftLogActions(this.ref);

  Future<void> clockIn() async {
    return CurShiftDependencyProvider.get<Future<void>>(
      ref: ref,
      builder: (userId, joinedShift) async {
        final service = ref.read(shiftLogServiceProvider);
        await service.clockIn(userId: userId, shiftId: joinedShift.shift.id);
      },
    ).value;
  }

  Future<void> clockOut() async {
    return CurShiftDependencyProvider.get<Future<void>>(
      ref: ref,
      builder: (userId, joinedShift) async {
        final service = ref.read(shiftLogServiceProvider);
        await service.clockOut(userId: userId, shiftId: joinedShift.shift.id);
      },
    ).value;
  }
}