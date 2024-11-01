import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/z_graveyard/cur_shifts/cur_user_joined_shifts_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

sealed class CurUserJoinedShiftState {
  const CurUserJoinedShiftState();
}

class CurUserJoinedShiftLoading extends CurUserJoinedShiftState {
  const CurUserJoinedShiftLoading();
}

class CurUserJoinedShiftLoaded extends CurUserJoinedShiftState {
  final JoinedShiftModel? joinedShift;
  const CurUserJoinedShiftLoaded(this.joinedShift);
}

final curUserJoinedShiftProvider = NotifierProvider<CurUserJoinedShiftNotifier, CurUserJoinedShiftState>(() {
  return CurUserJoinedShiftNotifier();
});

class CurUserJoinedShiftNotifier extends Notifier<CurUserJoinedShiftState> {
  @override
  CurUserJoinedShiftState build() {
    final shifts = ref.watch(curUserJoinedShiftsListenerProvider);
    if (shifts == null) {
      return const CurUserJoinedShiftLoading();
    }
    return CurUserJoinedShiftLoaded(shifts.firstOrNull);
  }
}
