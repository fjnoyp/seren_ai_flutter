
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

class JoinedTaskModel{
  final TaskModel task; 
  final UserModel? authorUser; 
  final ProjectModel? project; 
  final TeamModel? team; 

  JoinedTaskModel({required this.task, required this.authorUser, required this.project, this.team});
  

  static Future<JoinedTaskModel> fromUserModel(WidgetRef ref, TaskModel taskModel) async {

    final authorId = taskModel.authorUserId;
    final authorUser = await ref.read(usersReadProvider).getItem(id: authorId);

    final projectId = taskModel.parentProjectId;
    final project = await ref.read(projectsReadProvider).getItem(id: projectId);

    final teamId = taskModel.parentTeamId;
    final team = teamId != null ? await ref.read(teamsReadProvider).getItem(id: teamId) : null;

    return JoinedTaskModel(task: taskModel, authorUser: authorUser, project: project, team: team);
  }
}