import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/cur_shift_dependecy_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shift_logs_service_provider.dart';

final curUserShiftLogActionsProvider = Provider<CurUserShiftLogActions>((ref) {
  return CurUserShiftLogActions(ref);
});

class CurUserShiftLogActions {
  final Ref ref;

  CurUserShiftLogActions(this.ref);

  Future<void> clockIn() async {
    return CurShiftDependencyProvider.get<Future<void>>(
      ref: ref,
      builder: (userId, shift) async {
        final service = ref.read(shiftLogServiceProvider);
        await service.clockIn(userId: userId, shiftId: shift.id);
      },
    ).value;
  }

  Future<void> clockOut() async {
    return CurShiftDependencyProvider.get<Future<void>>(
      ref: ref,
      builder: (userId, shift) async {
        final service = ref.read(shiftLogServiceProvider);
        await service.clockOut(userId: userId, shiftId: shift.id);
      },
    ).value;
  }
}
