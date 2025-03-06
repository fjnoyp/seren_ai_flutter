import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

final curSelectedProjectStreamProvider = StreamProvider<ProjectModel?>((ref) {
  final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
  if (projectId == null) return Stream.value(null);

  final projectsRepo = ref.read(projectsRepositoryProvider);
  return projectsRepo.watchById(projectId);
});

final curSelectedProjectIdNotifierProvider =
    NotifierProvider<CurSelectedProjectIdNotifier, String?>(() {
  return CurSelectedProjectIdNotifier();
});

class CurSelectedProjectIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Check access only when needed, don't watch continuously
    ref.listen(curUserViewableProjectsProvider, (previous, next) {
      if (next.value != null &&
          state != null &&
          !next.value!.any((e) => e.id == state!)) {
        log('User has no longer access to project ${state!}');
        _initializeDefaultProject();
      }
    });

    // Initial setup
    _initializeDefaultProject();
    return null;
  }

  void setProjectId(String projectId) {
    state = projectId;
  }

  Future<void> _initializeDefaultProject() async {
    try {
      final defaultId = await _findDefaultProjectId();
      if (defaultId != null && state == null) {
        setProjectId(defaultId);
      }
    } catch (e) {
      log('Error initializing default project: $e');
    }
  }

  Future<String?> _findDefaultProjectId() async {
    final curUser = ref.read(curUserProvider).value;
    if (curUser == null) {
      throw Exception('No user found');
    }

    // Try user's default project first
    if (curUser.defaultProjectId != null) {
      final defaultProject = await ref
          .read(projectsRepositoryProvider)
          .getById(curUser.defaultProjectId!);

      // Check if the default project is in the user's current org
      final curOrgId = ref.read(curSelectedOrgIdNotifierProvider);
      if (defaultProject != null && defaultProject.parentOrgId == curOrgId) {
        return defaultProject.id;
      }
    }

    // Fall back to first available project in the user's current org
    final orgId = ref.read(curSelectedOrgIdNotifierProvider)!;
    final userProjects = await ref
        .read(projectsRepositoryProvider)
        .getUserProjects(userId: curUser.id, orgId: orgId);
    if (userProjects.isNotEmpty) {
      final curOrgId = ref.read(curSelectedOrgIdNotifierProvider);
      return userProjects.firstWhere((p) => p.parentOrgId == curOrgId).id;
    }

    throw Exception('No project found');
  }

  // Public method to get current state or find default
  Future<String> getSelectedProjectOrDefault() async {
    if (state != null) return state!;

    final defaultId = await _findDefaultProjectId();
    if (defaultId != null) {
      setProjectId(defaultId);
      return defaultId;
    }

    throw Exception('No project found');
  }
}
