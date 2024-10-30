import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seren_ai_flutter/services/data/teams/models/joined_user_team_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/user_team_assignments/user_team_assignments_listener_team_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

final joinedUserTeamAssignmentsListenerTeamFamProvider =
    NotifierProvider.family<
        JoinedUserTeamAssignmentsListenerTeamFamNotifier,
        List<JoinedUserTeamAssignmentModel>?,
        String>(JoinedUserTeamAssignmentsListenerTeamFamNotifier.new);

class JoinedUserTeamAssignmentsListenerTeamFamNotifier
    extends FamilyNotifier<List<JoinedUserTeamAssignmentModel>?, String> {
  @override
  List<JoinedUserTeamAssignmentModel>? build(String arg) {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final teamId = arg;

    final userTeamAssignments =
        ref.watch(userTeamAssignmentsListenerTeamFamProvider(teamId));

    if (userTeamAssignments == null) {
      return;
    }

    final userIds = userTeamAssignments.map((assignment) => assignment.userId).toList();
    final authUsers = await ref.read(usersReadProvider).getItems(ids: userIds);

    final team = await ref.read(teamsReadProvider).getItem(id: teamId);

    final joinedAssignments = userTeamAssignments.map((assignment) {
      final UserModel? authUser =
          authUsers.firstWhereOrNull((user) => user.id == assignment.userId);
      return JoinedUserTeamAssignmentModel(
        teamAssignment: assignment,
        user: authUser,
        team: team,
      );
    }).toList();

    state = joinedAssignments;
  }
}
