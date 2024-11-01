import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shifts_repository.dart';

final shiftsProvider = StreamProvider.autoDispose
    .family<List<JoinedShiftModel>, String>((ref, userId) {
  return ref.watch(shiftsRepositoryProvider).watchUserShifts(
    userId: userId,
  );
});

final curUserShiftsProvider = StreamProvider.autoDispose<List<JoinedShiftModel>>((ref) {
  final curAuthUserState = ref.watch(curAuthStateProvider);
  final curUser = switch (curAuthUserState) {
    LoggedInAuthState() => curAuthUserState.user,
    _ => throw Exception('curUser is null'),
  };

  return ref.watch(shiftsRepositoryProvider).watchUserShifts(
    userId: curUser.id,
  );
});

