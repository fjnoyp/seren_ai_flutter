// Abbreviated linked data loading for displaying tasks in a list

// Task list item details provider
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

// Load related task data for displaying in a list
final taskRelationsListDetailsProvider =
    FutureProvider.family<TaskListItemDetails, TaskModel>((ref, task) async {
  final Future<ProjectModel?> projectFuture = ref
      .watch(projectsRepositoryProvider)
      .getProjectById(projectId: task.parentProjectId);
  final Future<List<UserModel>> assigneesFuture =
      ref.watch(usersRepositoryProvider).getTaskAssignedUsers(taskId: task.id);

  final project = await projectFuture;
  final assignees = await assigneesFuture;

  return TaskListItemDetails(
    project: project,
    assignees: assignees,
  );
});

class TaskListItemDetails {
  final ProjectModel? project;
  final List<UserModel> assignees;

  TaskListItemDetails({
    this.project,
    required this.assignees,
  });
}
