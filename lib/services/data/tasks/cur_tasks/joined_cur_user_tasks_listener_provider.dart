import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_assigned_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

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

  // TODO p5: not so efficient - any task change will require a complete recalculation
  Future<void> _listen() async {
    final watchedCurUserTasks = ref.watch(curUserViewableTasksListenerProvider);

    if(watchedCurUserTasks == null){
      return; 
    }

    final authorUserIds = watchedCurUserTasks.map((task) => task.authorUserId).toSet();
    final authorUsers = await ref.read(usersReadProvider).getItems(ids: authorUserIds);

    final Set<String> teamIds = watchedCurUserTasks
      .map((task) => task.parentTeamId)
      .where((id) => id != null)
      .map((id) => id!)
      .toSet();
    final teams = await ref.read(teamsReadProvider).getItems(ids: teamIds);


    final projectIds = watchedCurUserTasks
      .map((task) => task.parentProjectId)
      .toSet();
    final projects = await ref.read(projectsReadProvider).getItems(ids: projectIds);
    
    final joinedTasks = watchedCurUserTasks.map((task) {
      final authorUser = authorUsers.firstWhereOrNull((user) => user.id == task.authorUserId);
      final team = teams.firstWhereOrNull((team) => team.id == task.parentTeamId);
      final project = projects.firstWhereOrNull((project) => project.id == task.parentProjectId);
      return JoinedTaskModel(task: task, authorUser: authorUser, team: team, project: project);
    }).toList();

    state = joinedTasks;
  }
}
