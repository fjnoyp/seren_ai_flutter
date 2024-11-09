import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_assignments_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/joined_user_team_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_providers.dart';

import 'package:collection/collection.dart';

final joinedCurUserTeamAssignmentsListenerProvider =
    Provider<List<JoinedUserTeamAssignmentModel>?>((ref) {
  final watchedCurUserTeamAssignments =
      ref.watch(curUserTeamAssignmentsListenerProvider);

  if (watchedCurUserTeamAssignments == null) {
    return null;
  }

  List<JoinedUserTeamAssignmentModel> joinedTeamAssignments = [];

  // Use ref.listen to handle async operations
  ref.listen(curUserTeamAssignmentsListenerProvider, (_, __) async {
    final userIds = watchedCurUserTeamAssignments
        .map((assignment) => assignment.userId)
        .toList();
    final users = ref.read(userListProvider(userIds));

    final teamIds = watchedCurUserTeamAssignments
        .map((assignment) => assignment.teamId)
        .toSet();
    final teams = await ref.read(teamsReadProvider).getItems(ids: teamIds);

    joinedTeamAssignments = watchedCurUserTeamAssignments.map((teamAssignment) {
      final user = users.valueOrNull
          ?.firstWhereOrNull((user) => user.id == teamAssignment.userId);
      final team =
          teams.firstWhereOrNull((team) => team.id == teamAssignment.teamId);
      return JoinedUserTeamAssignmentModel(
          teamAssignment: teamAssignment, user: user, team: team);
    }).toList();
  });

  return joinedTeamAssignments;
});
