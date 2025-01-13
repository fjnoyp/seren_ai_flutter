// Abbreviated linked data loading for displaying tasks in a list

// Task list item details provider
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

// Load related task data for displaying in a list
final taskListItemRelationsFutureProvider = FutureProvider.autoDispose
    .family<TaskListItemRelations, TaskModel>((ref, task) async {
  final Future<ProjectModel?> projectFuture =
      ref.watch(projectsRepositoryProvider).getById(task.parentProjectId);

  final Future<List<UserModel>> assigneesFuture =
      ref.watch(usersRepositoryProvider).getTaskAssignedUsers(taskId: task.id);

  final Future<UserModel?> authorFuture =
      ref.watch(usersRepositoryProvider).getById(task.authorUserId);

  final project = await projectFuture;
  final assignees = await assigneesFuture;
  final author = await authorFuture;

  return TaskListItemRelations(
    project: project,
    assignees: assignees,
    author: author,
  );
});

class TaskListItemRelations {
  final ProjectModel? project;
  final List<UserModel> assignees;
  final UserModel? author;

  TaskListItemRelations({
    this.project,
    required this.assignees,
    this.author,
  });
}
