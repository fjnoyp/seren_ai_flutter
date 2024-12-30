import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/user_project_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/editing_project_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/joined_project_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/user_project_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/user_project_assignments_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService(ref);
});

class ProjectService {
  final Ref ref;
  final JoinedProjectModel _selectedProject;
  final JoinedProjectModel _editingProject;

  ProjectService(this.ref)
      : _selectedProject = ref.watch(selectedProjectProvider),
        _editingProject = ref.watch(editingProjectProvider);

  void createEmptyProject() {
    ref.read(editingProjectProvider.notifier).setToNewProject();
  }

  Future<void> loadProject(ProjectModel project) async {
    final selectedProjectNotifier = ref.read(selectedProjectProvider.notifier);
    final editingProjectNotifier = ref.read(editingProjectProvider.notifier);

    final joinedProject = await ref
        .read(joinedProjectsRepositoryProvider)
        .getJoinedProjectById(project.id);

    selectedProjectNotifier.setProject(joinedProject);
    editingProjectNotifier.setProject(joinedProject);
  }

  /// Returns true if the current editing project is valid to save.
  bool validateProject() => _editingProject.project.name.isNotEmpty;

  void updateProjectName(String name) {
    ref
        .read(editingProjectProvider.notifier)
        .setProject(_editingProject.copyWith(
          project: _editingProject.project.copyWith(name: name),
        ));
  }

  void updateDescription(String? description) {
    ref
        .read(editingProjectProvider.notifier)
        .setProject(_editingProject.copyWith(
          project: _editingProject.project.copyWith(description: description),
        ));
  }

  void updateAddress(String? address) {
    ref
        .read(editingProjectProvider.notifier)
        .setProject(_editingProject.copyWith(
          project: _editingProject.project.copyWith(address: address),
        ));
  }

  Future<void> updateAssignees(List<UserModel>? assignees) async {
    if (assignees == null) return;

    final userProjectAssignmentsDb = ref.read(userProjectAssignmentsDbProvider);

    final previousAssignments = await ref
        .read(userProjectAssignmentsRepositoryProvider)
        .getUserProjectAssignments(projectId: _selectedProject.project.id);

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
            projectId: _selectedProject.project.id, userId: e.id))
        .toList();

    if (newAssignments.isNotEmpty) {
      await userProjectAssignmentsDb.upsertItems(newAssignments);
    }

    // Update the state with new assignees
    ref
        .read(selectedProjectProvider.notifier)
        .setProject(_selectedProject.copyWith(assignees: assignees));
  }

  Future<void> saveProject() async {
    await ref.read(projectsDbProvider).upsertItem(_editingProject.project);
  }
}
