import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_read_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_tasks/cur_user_viewable_tasks_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/teams/teams_read_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/users_read_provider.dart';

import 'package:collection/collection.dart';

// TODO p2 : split out the providers here - there isn't always a need for this joined provider ... 
// It's inefficient 

final joinedCurUserTasksListenerProvider = NotifierProvider<
    JoinedCurUserTasksListenerNotifier,
    List<JoinedTaskModel>?>(JoinedCurUserTasksListenerNotifier.new);

class JoinedCurUserTasksListenerNotifier
    extends Notifier<List<JoinedTaskModel>?> {
  @override
  List<JoinedTaskModel>? build() {
    _listen();
    return null;
  }

  // TODO p4: not efficient - any task change will require a complete recalculation, also we must manually add fields to each task 
  // Can create a map or break sql reads 

  Future<void> _listen() async {
    final watchedCurUserTasks = ref.watch(curUserViewableTasksListenerProvider);

    if (watchedCurUserTasks == null) {
      return;
    }

    // NOTE - all joined data are read not watched 

    // Fetch author users
    final authorUserIds =
        watchedCurUserTasks.map((task) => task.authorUserId).toSet();
    final authorUsers =
        await ref.watch(usersReadProvider).getItems(ids: authorUserIds);

    // Fetch teams
    final Set<String> teamIds = watchedCurUserTasks
        .map((task) => task.parentTeamId)
        .where((id) => id != null)
        .map((id) => id!)
        .toSet();
    final teams = await ref.watch(teamsReadProvider).getItems(ids: teamIds);

    // Fetch projects
    final projectIds =
        watchedCurUserTasks.map((task) => task.parentProjectId).toSet();
    final projects =
        await ref.watch(projectsReadProvider).getItems(ids: projectIds);

    

    // Fetch assignments for all tasks
    final db = ref.watch(dbProvider);
    final assignmentsQuery = '''
    SELECT tua.task_id, u.* 
    FROM task_user_assignments tua
    JOIN users u ON tua.user_id = u.id
    WHERE tua.task_id IN (${watchedCurUserTasks.map((t) => "'${t.id}'").join(',')});
    ''';
    final assignmentsResults = await db.execute(assignmentsQuery);
    
    // Create a direct mapping of task id to assigned users
    final Map<String, List<UserModel>> taskAssignments = {};
    for (final result in assignmentsResults) {
      final taskId = result['task_id'] as String;
      final user = UserModel.fromJson(result);
      
      if (!taskAssignments.containsKey(taskId)) {
        taskAssignments[taskId] = [];
      }
      taskAssignments[taskId]!.add(user);
    }

    


    // Fetch comments for all tasks
    final commentsQuery = '''
    SELECT * FROM task_comments
    WHERE parent_task_id IN (${watchedCurUserTasks.map((t) => "'${t.id}'").join(',')})
    ORDER BY created_date DESC;
    ''';
    final commentsResults = await db.execute(commentsQuery);
    final comments = commentsResults.map((e) => TaskCommentsModel.fromJson(e)).toList();


    // Create joined tasks
    final joinedTasks = watchedCurUserTasks.map((task) {
      final authorUser =
          authorUsers.firstWhereOrNull((user) => user.id == task.authorUserId);
      final team =
          teams.firstWhereOrNull((team) => team.id == task.parentTeamId);
      final project = projects
          .firstWhereOrNull((project) => project.id == task.parentProjectId);
      final assignedUsers = taskAssignments[task.id] ?? [];
      final taskComments = comments.where((c) => c.parentTaskId == task.id).toList();
      return JoinedTaskModel(
          task: task, 
          authorUser: authorUser, 
          team: team, 
          project: project,
          assignees: assignedUsers,
          comments: taskComments);
    }).toList();

    state = joinedTasks;
  }
}
