import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shifts_provider.dart';

sealed class CurUserShiftState {
  const CurUserShiftState();
}

class CurUserShiftLoading extends CurUserShiftState {
  const CurUserShiftLoading();
}

class CurUserShiftLoaded extends CurUserShiftState {
  final JoinedShiftModel? joinedShift;
  const CurUserShiftLoaded(this.joinedShift);
}

class CurUserShiftError extends CurUserShiftState {
  final String errorMessage;
  const CurUserShiftError(this.errorMessage);
}

final curUserShiftStateProvider = NotifierProvider<CurUserShiftStateNotifier, CurUserShiftState>(() {
  return CurUserShiftStateNotifier();
});

class CurUserShiftStateNotifier extends Notifier<CurUserShiftState> {
  @override
  CurUserShiftState build() {
    final shifts = ref.watch(curUserShiftsProvider);
    return shifts.when(
      data: (shifts) => CurUserShiftLoaded(shifts.firstOrNull),
      loading: () => const CurUserShiftLoading(),
      error: (error, stack) => CurUserShiftError(
        kDebugMode ? '$error\n$stack' : 'Failed to load shift data'
      ),
    );
  }
}