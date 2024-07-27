import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/user_db_provider.dart';

import 'package:collection/collection.dart'; 

final joinedCurUserTasksListenerProvider = NotifierProvider<
    JoinedCurUserTasksListenerNotifier,
    List<JoinedTaskModel>?>(
  JoinedCurUserTasksListenerNotifier.new
);

class JoinedCurUserTasksListenerNotifier
    extends Notifier<List<JoinedTaskModel>?> {  

  @override
  List<JoinedTaskModel>? build() {
    _listen();
    return null;
  }

  // TODO: not so efficient - any task change will require a complete recalculation
  Future<void> _listen() async {
    final watchedCurUserTasks = ref.watch(curUserTasksListenerProvider);

    if(watchedCurUserTasks == null){
      return; 
    }

    final authorUserIds = watchedCurUserTasks.map((task) => task.authorUserId).toSet();
    final authorUsers = await ref.read(usersDbProvider).getItems(ids: authorUserIds);

    final Set<String> teamIds = watchedCurUserTasks
      .map((task) => task.parentTeamId)
      .where((id) => id != null)
      .map((id) => id!)
      .toSet();
    final teams = await ref.read(teamsDbProvider).getItems(ids: teamIds);


    final projectIds = watchedCurUserTasks
      .map((task) => task.parentProjectId)
      .toSet();
    final projects = await ref.read(projectsDbProvider).getItems(ids: projectIds);
    
    final joinedTasks = watchedCurUserTasks.map((task) {
      final authorUser = authorUsers.firstWhereOrNull((user) => user.id == task.authorUserId);
      final team = teams.firstWhereOrNull((team) => team.id == task.parentTeamId);
      final project = projects.firstWhereOrNull((project) => project.id == task.parentProjectId);
      return JoinedTaskModel(task: task, authorUser: authorUser, team: team, project: project);
    }).toList();

    state = joinedTasks;
  }
}
