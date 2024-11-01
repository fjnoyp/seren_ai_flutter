import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';

final shiftLogsProvider = StreamProvider.autoDispose
    .family<List<ShiftLogModel>, ({String userId, String shiftId, DateTime day})>((ref, args) {
  
  return ref.watch(shiftLogsRepositoryProvider).watchUserShiftLogsForDay(
    shiftId: args.shiftId,
    userId: args.userId,
    day: args.day,
  );
});

final curUserShiftLogsProvider = StreamProvider.autoDispose.family<List<ShiftLogModel>, ({String shiftId, DateTime day})>((ref, args) {
  final curAuthUserState = ref.watch(curAuthStateProvider);
  final curUser = switch (curAuthUserState) {
    LoggedInAuthState() => curAuthUserState.user,
    _ => throw Exception('curUser is null'),
  };

  return ref.watch(shiftLogsRepositoryProvider).watchUserShiftLogsForDay(
    shiftId: args.shiftId,
    userId: curUser.id,
    day: args.day.toUtc(),
  );
});
