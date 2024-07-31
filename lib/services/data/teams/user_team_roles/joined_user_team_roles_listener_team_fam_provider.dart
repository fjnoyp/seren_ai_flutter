import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/data/teams/models/joined_user_team_role_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/user_team_roles/user_team_roles_listener_team_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';


// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart'; 



final joinedUserTeamRolesListenerTeamFamProvider = NotifierProvider.family<
    JoinedUserTeamRolesListenerTeamFamNotifier,
    List<JoinedUserTeamRoleModel>?,
    String>(
  JoinedUserTeamRolesListenerTeamFamNotifier.new
);

class JoinedUserTeamRolesListenerTeamFamNotifier
    extends FamilyNotifier<List<JoinedUserTeamRoleModel>?, String> {


  @override
  List<JoinedUserTeamRoleModel>? build(String arg) {
    _listen(); 
    return null;
  }

  Future<void> _listen() async {
    final teamId = arg; 

    final userTeamRoles = ref.watch(userTeamRolesListenerTeamFamProvider(teamId));

    if(userTeamRoles == null){
      return;
    }

    final userIds = userTeamRoles.map((role) => role.userId).toList();
    final authUsers = await ref.read(usersReadProvider).getItems(ids: userIds);

    final team = await ref.read(teamsReadProvider).getItem(id: teamId); 

    final joinedRoles = userTeamRoles.map((role) {
      final UserModel? authUser =
          authUsers.firstWhereOrNull((user) => user.id == role.userId);
      return JoinedUserTeamRoleModel(
        teamRole: role,
        user: authUser,
        team: team,
      );
    }).toList();

    state = joinedRoles;
  }
}