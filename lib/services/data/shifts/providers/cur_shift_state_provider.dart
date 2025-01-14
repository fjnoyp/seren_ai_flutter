import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shifts_provider.dart';

final curShiftStateProvider = NotifierProvider<CurShiftStateNotifier, AsyncValue<ShiftModel?>>(() {
  return CurShiftStateNotifier();
});

class CurShiftStateNotifier extends Notifier<AsyncValue<ShiftModel?>> {
  @override
  AsyncValue<ShiftModel?> build() {
    final shifts = ref.watch(curUserShiftsProvider);
    return shifts.whenData((shifts) => shifts.firstOrNull);
  }
}