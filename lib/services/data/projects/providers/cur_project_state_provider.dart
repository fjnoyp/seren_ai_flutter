import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

// TODO: Double check if this is needed
// since we don't have any initial logic like in tasks and notes
final curProjectStateProvider =
    NotifierProvider<CurProjectStateNotifier, JoinedProjectModel>(() {
  return CurProjectStateNotifier();
});

class CurProjectStateNotifier extends Notifier<JoinedProjectModel> {
  @override
  JoinedProjectModel build() {
    return JoinedProjectModel.empty();
  }

  void setProject(JoinedProjectModel joinedProject) {
    state = joinedProject;
  }

  void setToNewProject() {
    final orgId = ref.read(curOrgIdProvider)!;
    final newProject = JoinedProjectModel.empty().copyWith(
      project: ProjectModel(
        name: 'New Project',
        description: '',
        parentOrgId: orgId,
      ),
    );
    state = newProject;
  }
}
