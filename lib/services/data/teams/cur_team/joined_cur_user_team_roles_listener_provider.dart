import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/joined_user_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/user_db_provider.dart';

import 'package:collection/collection.dart';

final joinedCurUserTeamRolesListenerProvider = NotifierProvider<
    JoinedCurUserTeamRolesListenerNotifier,
    List<JoinedUserTeamRoleModel>?>(
  JoinedCurUserTeamRolesListenerNotifier.new
);

class JoinedCurUserTeamRolesListenerNotifier
    extends Notifier<List<JoinedUserTeamRoleModel>?> {  

  @override
  List<JoinedUserTeamRoleModel>? build() {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final watchedCurUserTeamRoles = ref.watch(curUserTeamRolesListenerProvider);

    if(watchedCurUserTeamRoles == null){
      return; 
    }

    final userIds = watchedCurUserTeamRoles.map((role) => role.userId).toSet();
    final users = await ref.read(usersDbProvider).getItems(ids: userIds);

    final teamIds = watchedCurUserTeamRoles.map((role) => role.teamId).toSet();
    final teams = await ref.read(teamsDbProvider).getItems(ids: teamIds);
    
    final joinedTeamRoles = watchedCurUserTeamRoles.map((teamRole) {
      final user = users.firstWhereOrNull((user) => user.id == teamRole.userId);
      final team = teams.firstWhereOrNull((team) => team.id == teamRole.teamId);
      return JoinedUserTeamRoleModel(teamRole: teamRole, user: user, team: team);
    }).toList();

    state = joinedTeamRoles;
  }
}
