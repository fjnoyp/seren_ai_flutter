import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shifts_provider.dart';

sealed class CurShiftState {
  const CurShiftState();
}

class CurShiftLoading extends CurShiftState {
  const CurShiftLoading();
}

class CurShiftLoaded extends CurShiftState {
  final JoinedShiftModel? joinedShift;
  const CurShiftLoaded(this.joinedShift);
}

class CurShiftError extends CurShiftState {
  final String errorMessage;
  const CurShiftError(this.errorMessage);
}

final curShiftStateProvider = NotifierProvider<CurShiftStateNotifier, CurShiftState>(() {
  return CurShiftStateNotifier();
});

class CurShiftStateNotifier extends Notifier<CurShiftState> {
  @override
  CurShiftState build() {
    final shifts = ref.watch(curUserShiftsProvider);
    return shifts.when(
      data: (shifts) => CurShiftLoaded(shifts.firstOrNull),
      loading: () => const CurShiftLoading(),
      error: (error, stack) => CurShiftError(
        kDebugMode ? '$error\n$stack' : 'Failed to load shift data'
      ),
    );
  }
}