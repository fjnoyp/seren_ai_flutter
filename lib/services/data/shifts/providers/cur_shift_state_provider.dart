import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/providers/shifts_provider.dart';

final curShiftStateProvider = NotifierProvider<CurShiftStateNotifier, AsyncValue<JoinedShiftModel?>>(() {
  return CurShiftStateNotifier();
});

class CurShiftStateNotifier extends Notifier<AsyncValue<JoinedShiftModel?>> {
  @override
  AsyncValue<JoinedShiftModel?> build() {
    final shifts = ref.watch(curUserShiftsProvider);
    return shifts.whenData((shifts) => shifts.firstOrNull);
  }
}