import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_team_assignments_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/joined_user_team_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

import 'package:collection/collection.dart';

final joinedCurUserTeamAssignmentsListenerProvider = NotifierProvider<
    JoinedCurUserTeamAssignmentsListenerNotifier,
    List<JoinedUserTeamAssignmentModel>?>(JoinedCurUserTeamAssignmentsListenerNotifier.new);

class JoinedCurUserTeamAssignmentsListenerNotifier
    extends Notifier<List<JoinedUserTeamAssignmentModel>?> {
  @override
  List<JoinedUserTeamAssignmentModel>? build() {
    _listen();
    return null;
  }

  Future<void> _listen() async {
    final watchedCurUserTeamAssignments = ref.watch(curUserTeamAssignmentsListenerProvider);

    if (watchedCurUserTeamAssignments == null) {
      return;
    }

    final userIds = watchedCurUserTeamAssignments.map((assignment) => assignment.userId).toSet();
    final users = await ref.read(usersReadProvider).getItems(ids: userIds);

    final teamIds = watchedCurUserTeamAssignments.map((assignment) => assignment.teamId).toSet();
    final teams = await ref.read(teamsReadProvider).getItems(ids: teamIds);

    final joinedTeamAssignments = watchedCurUserTeamAssignments.map((teamAssignment) {
      final user = users.firstWhereOrNull((user) => user.id == teamAssignment.userId);
      final team = teams.firstWhereOrNull((team) => team.id == teamAssignment.teamId);
      return JoinedUserTeamAssignmentModel(
          teamAssignment: teamAssignment, user: user, team: team);
    }).toList();

    state = joinedTeamAssignments;
  }
}
