import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final curSelectedTaskIdNotifierProvider =
    NotifierProvider<CurSelectedTaskIdNotifier, String?>(() {
  return CurSelectedTaskIdNotifier();
});

class CurSelectedTaskIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTaskId(String taskId) => state = taskId;

  void clearTaskId() => state = null;

  Future<void> createNewTask() async {
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final selectedProjectId = await _getSelectedOrDefaultProjectId(curUser);

      final newTask = TaskModel(
        name: 'New Task',
        description: '',
        status: StatusEnum.open,
        authorUserId: curUser.id,
        parentProjectId: selectedProjectId,
      );

      await ref.read(tasksRepositoryProvider).upsertItem(newTask);

      state = newTask.id;
    } catch (e, __) {
      throw Exception('Failed to create new task: $e');
    }
  }

  Future<String> _getSelectedOrDefaultProjectId(UserModel curUser) async {
    // We need to use a try-catch here because curSelectedProjectIdNotifierProvider may not be initialized
    // when this function is called
    try {
      return ref.read(curSelectedProjectIdNotifierProvider)!;
    } catch (e) {
      final userDefaultProjectId = curUser.defaultProjectId;

      if (userDefaultProjectId != null) {
        return userDefaultProjectId;
      } else {
        final curOrgId = ref.read(curSelectedOrgIdNotifierProvider);
        if (curOrgId == null) throw Exception('No current org');

        final projects = await ref
            .read(projectsRepositoryProvider)
            .getUserProjects(userId: curUser.id, orgId: curOrgId);
        if (projects.isEmpty) {
          // As a task must be in a project, we can't create a new task if the user doesn't have any projects
          throw Exception('No projects found');
        }
        // if the user doesn't have a default project, we can use a random project
        return projects.first.id;
      }
    }
  }

  Future<Map<String, dynamic>> toReadableMap() async {
    if (state == null) return {'error': 'No editing task'};

    final curTask = await ref.read(tasksRepositoryProvider).getById(state!);
    if (curTask == null) return {'error': 'Task not found'};

    final curAssignees = await ref
        .read(usersRepositoryProvider)
        .getTaskAssignedUsers(taskId: state!);

    return {
      'task': {
        'name': curTask.name,
        'description': curTask.description,
        'status': curTask.status,
        'due_date': curTask.dueDate?.toIso8601String(),
      },
      'assignees': curAssignees.map((user) => user.email).toList(),
    };
  }
}
