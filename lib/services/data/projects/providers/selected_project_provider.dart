import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/joined_project_repository.dart';

final selectedProjectProvider =
    NotifierProvider<SelectedProjectNotifier, JoinedProjectModel>(() {
  return SelectedProjectNotifier();
});

class SelectedProjectNotifier extends Notifier<JoinedProjectModel> {
  @override
  JoinedProjectModel build() {
    final curUser = ref.watch(curUserProvider).value;

    // Defaults to user default project
    if (curUser != null && curUser.defaultProjectId != null) {
      ref
          .read(joinedProjectsRepositoryProvider)
          .getJoinedProjectById(curUser.defaultProjectId!)
          .then((project) => state = project);
    }

    // Emits an empty project while user (or its default project) is null
    return JoinedProjectModel.empty();
  }

  void setProject(JoinedProjectModel joinedProject) {
    state = joinedProject;
  }
}
