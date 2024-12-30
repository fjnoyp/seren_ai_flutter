import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/joined_project_repository.dart';
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

    setToDefaultOrFirstAssignedProject(curUser);

    final userProjects = ref.watch(curUserViewableProjectsProvider).value ?? [];
    if (userProjects.isNotEmpty &&
        state.value != null &&
        !userProjects.any((e) => e.id == state.value!.project.id)) {
      log('User has no longer access to ${state.value!.project.name}');
      state = AsyncError(
          'User has no longer access to this project', StackTrace.current);
    }

    return const AsyncLoading();
  }

  void setProject(String projectId) {
    ref
        .read(joinedProjectsRepositoryProvider)
        .getJoinedProjectById(projectId)
        .then((joinedProject) => state = AsyncData(joinedProject));
  }

  void setToDefaultOrFirstAssignedProject(UserModel user) {
    // Defaults to user default project
    if (user.defaultProjectId != null) {
      setProject(user.defaultProjectId!);
    } else {
      // Defaults to some assigned project when user default project is null
      final userProjects =
          ref.watch(curUserViewableProjectsProvider).value ?? [];
      if (userProjects.isNotEmpty) {
        setProject(userProjects.first.id);
      }
    }
  }
}
