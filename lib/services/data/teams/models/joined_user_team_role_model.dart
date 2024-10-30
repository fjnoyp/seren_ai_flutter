import 'package:seren_ai_flutter/services/data/teams/models/user_team_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

class JoinedUserTeamRoleModel {
  final UserTeamAssignmentModel teamAssignment;
  final UserModel? user;
  final TeamModel? team;

  JoinedUserTeamRoleModel({
    required this.teamAssignment,
    required this.user,
    required this.team,
  });
}
