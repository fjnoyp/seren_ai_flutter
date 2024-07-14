import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_roles_list_listener_database_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';

final curTeamIdProvider =
    StateNotifierProvider<CurTeamIdNotifier, String?>((ref) {
  return CurTeamIdNotifier(ref);
});

class CurTeamIdNotifier extends StateNotifier<String?> {
  final Ref ref;

  CurTeamIdNotifier(this.ref) : super(null) {
    _init();
  }

  void _init() {
    final watchedCurUserTeamRoles = ref.watch<List<UserTeamRoleModel>?>(curUserTeamRolesListListenerDatabaseProvider);
      if (watchedCurUserTeamRoles != null) {
        final currentTeamId = state;
        final isInCurrentTeam = watchedCurUserTeamRoles
            .any((teamRole) => teamRole.teamId == currentTeamId);

        if (!isInCurrentTeam) {
          state = null;
        }
      } else {
        state = null;
      }
  
  }

  void setTeamId(String? teamId) {
    state = teamId;
  }

  String? getTeamId() {
    return state;
  }
}
