
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

class JoinedTaskModel{
  final TaskModel task; 
  final UserModel? authorUser; 
  final ProjectModel? project; 
  final TeamModel? team; 
  final List<UserModel> assignees;
  final List<TaskCommentsModel> comments;
  
  JoinedTaskModel({required this.task, required this.authorUser, required this.project, this.team, required this.assignees, required this.comments});

  JoinedTaskModel copyWith({
    TaskModel? task,
    UserModel? authorUser,
    ProjectModel? project,
    TeamModel? team,
    List<UserModel>? assignees,
    List<TaskCommentsModel>? comments,
  }) {
    return JoinedTaskModel(
      task: task ?? this.task,
      authorUser: authorUser ?? this.authorUser,
      project: project ?? this.project,
      team: team ?? this.team,
      assignees: assignees ?? this.assignees,
      comments: comments ?? this.comments,
    );
  }
  

  /*
  static Future<JoinedTaskModel> fromTaskModel(WidgetRef ref, TaskModel taskModel) async {

    final authorId = taskModel.authorUserId;
    final authorUser = await ref.read(usersReadProvider).getItem(id: authorId);

    final projectId = taskModel.parentProjectId;
    final project = await ref.read(projectsReadProvider).getItem(id: projectId);

    final teamId = taskModel.parentTeamId;
    final team = teamId != null ? await ref.read(teamsReadProvider).getItem(id: teamId) : null;

    // TODO p5: fetch assignees and comments as well 

    return JoinedTaskModel(task: taskModel, authorUser: authorUser, project: project, team: team);
  }
  */
}