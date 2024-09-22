
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/cur_team/cur_user_viewable_teams_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/team_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_in_project_listener_provider.dart';

/// Provide the selectable projects/teams/users based on the current task fields from @curTaskProvider
final curTaskSelectionOptionsProvider = NotifierProvider<CurTaskSelectionOptionsNotifier, TaskSelectionOptionsState>(() {
  return CurTaskSelectionOptionsNotifier();
});

class TaskSelectionOptionsState {
  final List<ProjectModel> selectableProjects;
  final List<TeamModel> selectableTeams;
  final List<UserModel> selectableUsers;

  TaskSelectionOptionsState({
    required this.selectableProjects,
    required this.selectableTeams,
    required this.selectableUsers,
  });
}

// === NOTE === 
// This is inefficient as it groups state together
// But it allows for easy access to all the options in the UI for the AI in the future 
// TODO p5: investigate if the AlwaysAliveListenerProviders created when doing select on the fields here can cause memory issues down the line 
class CurTaskSelectionOptionsNotifier extends Notifier<TaskSelectionOptionsState> {  

  @override
  TaskSelectionOptionsState build() {

    final watchedTeams = ref.watch(curUserViewableTeamsListenerProvider);

    final watchedProjects = ref.watch(curUserViewableProjectsListenerProvider);

    final curProjectId = ref.watch(curTaskProjectIdProvider); 
    
    final usersInProject = curProjectId != null ? ref.watch(usersInProjectListenerProvider(curProjectId)) : <UserModel>[];

    final watchedCurAuthUser = ref.watch(curAuthUserProvider);

    final usersInProjectWithCurrentUser = [
      ...?usersInProject,
      if (watchedCurAuthUser != null) watchedCurAuthUser,
    ];

    return TaskSelectionOptionsState(
      selectableProjects: watchedProjects ?? [],
      selectableTeams: watchedTeams ?? [],
      selectableUsers: usersInProjectWithCurrentUser ?? [],
    );
  }



}
