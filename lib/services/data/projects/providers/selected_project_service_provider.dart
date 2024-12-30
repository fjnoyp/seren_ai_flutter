import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/user_project_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/joined_project_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/user_project_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/user_project_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final selectedProjectServiceProvider =
    NotifierProvider<SelectedProjectNotifier, AsyncValue<JoinedProjectModel>>(
        () => SelectedProjectNotifier());

class SelectedProjectNotifier extends Notifier<AsyncValue<JoinedProjectModel>> {
  @override
  AsyncValue<JoinedProjectModel> build() {
    final curUser = ref.watch(curUserProvider).value;

    if (curUser == null) {
      return AsyncError('No user found', StackTrace.current);
    }

    // Defaults to user default project
    if (curUser.defaultProjectId != null) {
      ref
          .read(joinedProjectsRepositoryProvider)
          .getJoinedProjectById(curUser.defaultProjectId!)
          .then((project) => state = AsyncData(project));
    } else {
      // Emits some assigned project while user default project is null
      ref
          .read(projectsRepositoryProvider)
          .getUserProjects(userId: curUser.id)
          .then(
            (userProjects) async => state = AsyncData(
              await ref
                  .read(joinedProjectsRepositoryProvider)
                  .getJoinedProjectById(userProjects.first.id),
            ),
          );
    }

    return const AsyncLoading();
  }

  void setProject(JoinedProjectModel joinedProject) {
    state = AsyncData(joinedProject);
  }

  Future<void> updateAssignees(List<UserModel>? assignees) async {
    if (assignees == null) return;

    final userProjectAssignmentsDb = ref.read(userProjectAssignmentsDbProvider);

    final previousAssignments = await ref
        .read(userProjectAssignmentsRepositoryProvider)
        .getUserProjectAssignments(projectId: state.value!.project.id);

    for (var assignment in previousAssignments) {
      if (!assignees.any((e) => e.id == assignment.id)) {
        await userProjectAssignmentsDb.deleteItem(assignment.id);
      }
    }

    // Only create new assignments for users that weren't previously assigned
    final newAssignments = assignees
        .where((newAssignee) => !previousAssignments
            .any((prevAssignee) => prevAssignee.id == newAssignee.id))
        .map((e) => UserProjectAssignmentModel(
            projectId: state.value!.project.id, userId: e.id))
        .toList();

    if (newAssignments.isNotEmpty) {
      await userProjectAssignmentsDb.upsertItems(newAssignments);
    }

    // Update the state with new assignees
    ref
        .read(selectedProjectServiceProvider.notifier)
        .setProject(state.value!.copyWith(assignees: assignees));
  }
}
