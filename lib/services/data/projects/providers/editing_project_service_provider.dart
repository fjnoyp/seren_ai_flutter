import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/joined_project_repository.dart';

final editingProjectServiceProvider =
    NotifierProvider<EditingProjectService, JoinedProjectModel>(() {
  return EditingProjectService();
});

class EditingProjectService extends Notifier<JoinedProjectModel> {
  @override
  JoinedProjectModel build() {
    return createNewProject();
  }

  JoinedProjectModel createNewProject() {
    final orgId = ref.read(curOrgIdProvider)!;
    final newProject = JoinedProjectModel.empty().copyWith(
      project: ProjectModel(
        name: 'New Project',
        description: '',
        parentOrgId: orgId,
      ),
    );
    state = newProject;
    return newProject;
  }

  Future<void> loadProject(ProjectModel project) async {
    final joinedProject = await ref
        .read(joinedProjectsRepositoryProvider)
        .getJoinedProjectById(project.id);

    state = joinedProject;
  }

  /// Returns true if the current editing project is valid to save.
  bool get isValidProject => state.project.name.isNotEmpty;

  void updateProject({
    String? name,
    String? description,
    String? address,
  }) {
    state = state.copyWith(
      project: state.project.copyWith(
        name: name,
        description: description,
        address: address,
      ),
    );
  }

  Future<void> saveProject() async {
    await ref.read(projectsDbProvider).upsertItem(state.project);
  }
}
