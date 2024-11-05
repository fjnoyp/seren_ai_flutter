import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shifts_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

// TODO p2: we provide shifts ignoring what current org is 
// If user is in multiple orgs, we show all shifts which could cause confusion
final curUserShiftsProvider = StreamProvider.autoDispose<List<JoinedShiftModel>>((ref) {
  return CurAuthDependencyProvider.watchStream<List<JoinedShiftModel>>(
    ref: ref,
    builder: (userId) {
      return ref.watch(shiftsRepositoryProvider).watchUserShifts(userId: userId);
    },
  );
});
