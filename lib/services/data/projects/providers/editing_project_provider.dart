import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';

final editingProjectProvider =
    NotifierProvider<EditingProjectNotifier, ProjectModel>(() {
  return EditingProjectNotifier();
});

class EditingProjectNotifier extends Notifier<ProjectModel> {
  @override
  ProjectModel build() {
    return createNewProject();
  }

  ProjectModel createNewProject() {
    final orgId = ref.read(curOrgIdProvider)!;
    final newProject = ProjectModel(
      name: 'New Project',
      description: '',
      parentOrgId: orgId,
    );
    state = newProject;
    return newProject;
  }

  Future<void> setProject(ProjectModel project) async {
    state = project;
  }

  /// Returns true if the current editing project is valid to save.
  bool get isValidProject => state.name.isNotEmpty;

  void updateProject({
    String? name,
    String? description,
    String? address,
  }) {
    state = state.copyWith(
      name: name,
      description: description,
      address: address,
    );
  }

  Future<void> saveProject() async {
    await ref.read(projectsDbProvider).upsertItem(state);
  }
}
