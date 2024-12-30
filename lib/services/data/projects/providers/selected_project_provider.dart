import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final selectedProjectProvider =
    NotifierProvider<SelectedProjectNotifier, AsyncValue<ProjectModel>>(
        () => SelectedProjectNotifier());

class SelectedProjectNotifier extends Notifier<AsyncValue<ProjectModel>> {
  @override
  AsyncValue<ProjectModel> build() {
    final curUser = ref.watch(curUserProvider).value;

    if (curUser == null) {
      return AsyncError('No user found', StackTrace.current);
    }

    setToDefaultOrFirstAssignedProject(curUser);

    final userProjects = ref.watch(curUserViewableProjectsProvider).value ?? [];
    if (userProjects.isNotEmpty &&
        state.value != null &&
        !userProjects.any((e) => e.id == state.value!.id)) {
      log('User has no longer access to ${state.value!.name}');
      state = AsyncError(
          'User has no longer access to this project', StackTrace.current);
    }

    return const AsyncLoading();
  }

  void setProject(ProjectModel project) {
    state = AsyncData(project);
  }

  Future<void> setToDefaultOrFirstAssignedProject(UserModel user) async {
    // Defaults to user default project
    if (user.defaultProjectId != null) {
      final defaultProject = await ref
          .watch(projectsRepositoryProvider)
          .getProjectById(projectId: user.defaultProjectId!);
      if (defaultProject != null) {
        setProject(defaultProject);
      }
    } else {
      // Defaults to some assigned project when user default project is null
      final userProjects =
          ref.watch(curUserViewableProjectsProvider).value ?? [];
      if (userProjects.isNotEmpty) {
        setProject(userProjects.first);
      }
    }
  }
}
