import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/data/teams/models/joined_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_cacher_database_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/user_team_roles/user_team_roles_listener_fam_provider.dart';

import 'package:seren_ai_flutter/services/data/users/users_cacher_database_provider.dart';


final joinedUserTeamRolesListenerFamProvider = NotifierProvider.family<
    JoinedUserTeamRolesListenerFamNotifier,
    List<JoinedTeamRoleModel>?,
    String>(
  JoinedUserTeamRolesListenerFamNotifier.new
);

class JoinedUserTeamRolesListenerFamNotifier
    extends FamilyNotifier<List<JoinedTeamRoleModel>?, String> {


  @override
  List<JoinedTeamRoleModel>? build(String arg) {
    _listen(); 
    return null;
  }

  Future<void> _listen() async {
    final teamId = arg; 

    final userTeamRoles = ref.watch(userTeamRolesListenerFamProvider(teamId));

    if(userTeamRoles == null){
      return;
    }

    final userIds = userTeamRoles.map((role) => role.userId).toList();
    final authUsers = await ref.read(usersCacherDatabaseProvider).getItems(ids: userIds);

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