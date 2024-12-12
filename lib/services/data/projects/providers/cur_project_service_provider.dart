import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/user_project_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/joined_project_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/user_project_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/user_project_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curProjectServiceProvider = Provider<CurProjectService>((ref) {
  return CurProjectService(ref);
});

class CurProjectService {
  final Ref ref;
  final JoinedProjectModel _state;
  final CurProjectStateNotifier _notifier;

  CurProjectService(this.ref)
      : _state = ref.watch(curProjectStateProvider),
        _notifier = ref.watch(curProjectStateProvider.notifier);

  void setToNewProject() {
    _notifier.setToNewProject();
  }

  Future<void> loadProject(ProjectModel project) async {
    _notifier.setProject(await ref
        .read(joinedProjectsRepositoryProvider)
        .getJoinedProjectById(project.id));
  }

  String get curProjectId => _state.project.id;

  bool isValidProject() => _state.project.name.isNotEmpty;

  void updateProjectName(String name) {
    _notifier.setProject(_state.copyWith(
      project: _state.project.copyWith(name: name),
    ));
  }

  void updateDescription(String? description) {
    _notifier.setProject(_state.copyWith(
      project: _state.project.copyWith(description: description),
    ));
  }

  void updateAddress(String? address) {
    _notifier.setProject(_state.copyWith(
      project: _state.project.copyWith(address: address),
    ));
  }

  Future<void> updateAssignees(List<UserModel>? assignees) async {
    if (assignees == null) return;

    final userProjectAssignmentsDb = ref.read(userProjectAssignmentsDbProvider);

    final previousAssignments = await ref
        .read(userProjectAssignmentsRepositoryProvider)
        .getUserProjectAssignments(projectId: _state.project.id);

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
            projectId: _state.project.id, userId: e.id))
        .toList();

    if (newAssignments.isNotEmpty) {
      await userProjectAssignmentsDb.upsertItems(newAssignments);
    }

    // Update the state with new assignees
    _notifier.setProject(_state.copyWith(assignees: assignees));
  }

  Future<void> saveProject() async {
    await ref.read(projectsDbProvider).upsertItem(_state.project);
  }
}
