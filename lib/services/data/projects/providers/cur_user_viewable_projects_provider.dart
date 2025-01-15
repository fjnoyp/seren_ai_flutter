import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

/// Stream provider for projects the current user can view
final curUserViewableProjectsProvider =
    StreamProvider.autoDispose<List<ProjectModel>>(
  (ref) {
    final projectsRepo = ref.watch(projectsRepositoryProvider);

    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) {
        final orgId = ref.watch(curSelectedOrgIdNotifierProvider);

        if (orgId == null) {
          return const Stream.empty();
        }

        return projectsRepo.watchUserProjects(userId: userId, orgId: orgId);
      },
    );
  },
);
