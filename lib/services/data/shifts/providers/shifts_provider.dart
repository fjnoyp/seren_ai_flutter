import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/repositories/shifts_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

final curUserShiftsProvider = StreamProvider.autoDispose<List<ShiftModel>>((ref) {
  return CurAuthDependencyProvider.watchStream<List<ShiftModel>>(
    ref: ref,
    builder: (userId) {
      final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
      if (curOrgId == null) throw Exception('No org selected');
      return ref.watch(shiftsRepositoryProvider).watchUserShifts(userId: userId, orgId: curOrgId);
    },
  );
});
