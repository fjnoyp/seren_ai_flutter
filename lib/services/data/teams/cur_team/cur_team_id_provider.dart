import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_roles_list_listener_database_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';

// TODO: not used yet ...
final curTeamIdProvider =
    StateNotifierProvider<CurTeamIdNotifier, String?>((ref) {
  return CurTeamIdNotifier(ref);
});

class CurTeamIdNotifier extends StateNotifier<String?> {
  final Ref ref;

  static const bool _autoSetTeamId = true;

  CurTeamIdNotifier(this.ref) : super(null) {
    _init();
  }

  void _init() {
    final watchedCurUserTeamRoles = ref.watch<List<UserTeamRoleModel>?>(
        curUserTeamRolesListListenerDatabaseProvider);

    bool hasTeamRoles =
        watchedCurUserTeamRoles != null && watchedCurUserTeamRoles.isNotEmpty;

    // Default to choosing first team is autoset
    if (state == null) {
      if (hasTeamRoles && _autoSetTeamId) {
        state = watchedCurUserTeamRoles.first.teamId;
      }
      return;
    }

    // If no more team roles unset team
    if (!hasTeamRoles) {
      state = null;
      return;
    }

    // If team id is not in the list, unset team or update if autoset

    final currentTeamId = state;
    final isInCurrentTeam = watchedCurUserTeamRoles
        .any((teamRole) => teamRole.teamId == currentTeamId);

    if (isInCurrentTeam)
      return;
    else if (_autoSetTeamId) {
      state = watchedCurUserTeamRoles.first.teamId;
      return;
    } else {
      state = null;
      return;
    }
  }

  void setTeamId(String? teamId) {
    state = teamId;
  }

  String? getTeamId() {
    return state;
  }
}
