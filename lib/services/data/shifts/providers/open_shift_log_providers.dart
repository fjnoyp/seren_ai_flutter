import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shift_logs_repository.dart';

final openShiftLogProvider = StreamProvider.autoDispose
    .family<ShiftLogModel?, ({String userId, String shiftId})>((ref, args) {
  
  return ref.watch(shiftLogsRepositoryProvider).watchCurrentOpenLog(
    shiftId: args.shiftId,
    userId: args.userId,
  );
});

final curUserOpenShiftLogProvider = StreamProvider.autoDispose.family<ShiftLogModel?, String>((ref, shiftId) {
  final curAuthUserState = ref.watch(curAuthStateProvider);
  final curUser = switch (curAuthUserState) {
    LoggedInAuthState() => curAuthUserState.user,
    _ => throw Exception('curUser is null'),
  };

  return ref.watch(shiftLogsRepositoryProvider).watchCurrentOpenLog(
    shiftId: shiftId,
    userId: curUser.id,
  );
});
