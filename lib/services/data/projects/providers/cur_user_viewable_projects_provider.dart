import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

// TODO p0: update the underlying SQL query to get all projects for admins
// Instead of having logic here to do that

/// Stream provider for projects the current user can view
final curUserViewableProjectsProvider =
    StreamProvider.autoDispose<List<ProjectModel>>(
  (ref) {
    final projectsRepo = ref.watch(projectsRepositoryProvider);

    return IsCurUserOrgAdminDependencyProvider.watchStream(
      ref: ref,
      builder: (isOrgAdmin) {
        if (isOrgAdmin) {
          // If user is org admin, return all projects for the org
          final curOrgId = ref.watch(curOrgIdProvider);
          return projectsRepo.watchOrgProjects(orgId: curOrgId!);
        } else {
          // Otherwise, return only projects user has access to
          return CurAuthDependencyProvider.watchStream(
            ref: ref,
            builder: (userId) => projectsRepo.watchUserProjects(userId: userId),
          );
        }
      },
    );
  },
);
