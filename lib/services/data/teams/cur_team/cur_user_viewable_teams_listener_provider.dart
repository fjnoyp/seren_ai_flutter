// Get the current org
// And current org assignment

// If org admin - get all teams in that org via team's parent_org_id

// If not - get all teams in that org that have a team assignment for the current user

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/joined_cur_user_team_assignments_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';

final curUserViewableTeamsListenerProvider =
    NotifierProvider<CurUserViewableTeamsListenerProvider, List<TeamModel>?>(
        CurUserViewableTeamsListenerProvider.new);

class CurUserViewableTeamsListenerProvider extends Notifier<List<TeamModel>?> {
  @override
  List<TeamModel>? build() {
    final watchedIsCurUserOrgAdmin = ref.watch(curUserOrgRoleProvider);

    if (watchedIsCurUserOrgAdmin.valueOrNull == true) {
      final watchedCurOrgId = ref.watch(curOrgIdProvider);

      final query =
          "SELECT * FROM teams WHERE parent_org_id = '$watchedCurOrgId'";

      final db = ref.read(dbProvider);

      final subscription = db.watch(query).listen((results) {
        List<TeamModel> items =
            results.map((e) => TeamModel.fromJson(e)).toList();
        state = items;
      });

      // Cancel the subscription when the notifier is disposed
      ref.onDispose(() {
        subscription.cancel();
      });
    } else {
      // get all teams in that org that have a team assignment for the current user
      final joinedTeamAssignments =
          ref.watch(joinedCurUserTeamAssignmentsListenerProvider);
      if (joinedTeamAssignments != null) {
        return joinedTeamAssignments
            .where((e) => e.team != null)
            .map((e) => e.team!)
            .toList();
      }
      return [];
    }

    // Return the initial state
    return null;
  }
}
