import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/cur_shifts/cur_user_shifts_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';

final curUserJoinedShiftsListenerProvider = NotifierProvider<
    CurUserJoinedShiftsListenerNotifier,
    List<JoinedShiftModel>?>(CurUserJoinedShiftsListenerNotifier.new);

class CurUserJoinedShiftsListenerNotifier
    extends Notifier<List<JoinedShiftModel>?> {
  @override
  List<JoinedShiftModel>? build() {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final watchedCurUserShifts = ref.watch(curUserShiftsListenerProvider);

    if (watchedCurUserShifts == null) {
      return;
    }

    // Fetch projects
    final projectIds = watchedCurUserShifts.map((shift) => shift.parentProjectId).toSet();
    final projects = await ref.read(projectsReadProvider).getItems(ids: projectIds);

    // Create joined shifts
    final joinedShifts = watchedCurUserShifts.map((shift) {
      final project = projects.firstWhere((project) => project.id == shift.parentProjectId);
      return JoinedShiftModel(
        shift: shift,
        parentProject: project,
      );
    }).toList();

    final curAuthUserState = ref.read(curAuthUserProvider);
    if (curAuthUserState is LoggedInAuthState) {
      final curAuthUserDefaultProjectId =
          curAuthUserState.user.defaultProjectId;
      joinedShifts.sort((a, b) =>
          (a.parentProject?.id ?? '') == curAuthUserDefaultProjectId ? -1 : 1);
    }

    state = joinedShifts;
  }
}
