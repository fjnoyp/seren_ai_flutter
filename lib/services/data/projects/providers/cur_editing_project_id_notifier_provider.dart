import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

final curEditingProjectIdNotifierProvider =
    NotifierProvider<EditingProjectIdNotifier, String?>(() {
  return EditingProjectIdNotifier();
});

class EditingProjectIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setProjectId(String projectId) => state = projectId;

  void clearProjectId() => state = null;

  Future<void> createNewProject() async {
    try {
      final orgId = ref.read(curSelectedOrgIdNotifierProvider);
      if (orgId == null) return;

      final newProject = ProjectModel(
        name: 'New Project',
        description: '',
        parentOrgId: orgId,
      );

      await ref.read(projectsRepositoryProvider).upsertItem(newProject);

      state = newProject.id;
    } catch (_, __) {
      throw Exception('Failed to create new project');
    }
  }
}
