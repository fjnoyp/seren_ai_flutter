import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shifts_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

final curUserShiftsProvider =
    StreamProvider.autoDispose<List<JoinedShiftModel>>((ref) {
  return CurAuthDependencyProvider.watchStream<List<JoinedShiftModel>>(
    ref: ref,
    builder: (userId) {
      return ref
          .watch(shiftsRepositoryProvider)
          .watchUserShifts(userId: userId, orgId: ref.read(curOrgIdProvider)!);
    },
  );
});
