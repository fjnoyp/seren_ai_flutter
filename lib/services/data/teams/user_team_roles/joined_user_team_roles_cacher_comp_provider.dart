import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/data/teams/models/joined_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_cacher_database_provider.dart';

import 'package:seren_ai_flutter/services/data/teams/user_team_roles/user_team_roles_cacher_database_provider.dart';
import 'package:seren_ai_flutter/services/data/users/users_cacher_database_provider.dart';


final joinedUserTeamRolesCacherCompProvider = StateNotifierProvider.family<
    JoinedUserTeamRolesCompNotifier,
    List<JoinedTeamRoleModel>,
    String>((ref, teamId) {
  return JoinedUserTeamRolesCompNotifier(ref, teamId);
});

class JoinedUserTeamRolesCompNotifier
    extends StateNotifier<List<JoinedTeamRoleModel>> {
  final Ref ref;
  final String teamId;

  JoinedUserTeamRolesCompNotifier(this.ref, this.teamId) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    // Get the user team roles of the provided team id 
    final userTeamRoles = await ref
        .read(userTeamRolesCacherDatabaseProvider(teamId))
        .getItems(eqFilters: [
      {'key': 'team_id', 'value': teamId}
    ]);

    if(userTeamRoles.isEmpty){
      state = [];
      return;
    }

    // Get the users specified in the user team roles 
    final userIds = userTeamRoles.map((role) => role.userId).toList();
    final authUsers =
        await ref.read(usersCacherDatabaseProvider).getItems(ids: userIds);

    final team = (await ref.read(teamsCacherDatabaseProvider).getItem(id: teamId))!;

    final joinedRoles = userTeamRoles.map((role) {
      final authUser =
          authUsers.firstWhere((user) => user.id == role.userId);
      return JoinedTeamRoleModel(
        teamRole: role,
        user: authUser,
        team: team,
      );
    }).toList();

    state = joinedRoles;
  }
}
