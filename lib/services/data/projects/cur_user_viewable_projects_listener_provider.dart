import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/is_cur_user_org_admin_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_listener_fam_provider.dart';

final curUserViewableProjectsListenerProvider =
    Provider<List<ProjectModel>?>((ref) {
  final watchedIsCurUserOrgAdmin = ref.watch(isCurUserOrgAdminListenerProvider);

  if (watchedIsCurUserOrgAdmin) {
    final watchedCurOrgId = ref.watch(curOrgIdProvider);

    if(watchedCurOrgId == null) {
      return [];
    }

    final allProjects = ref.watch(projectsListenerFamProvider(watchedCurOrgId));

    return allProjects ?? [];
  } else {
    // get all projects that the current user is assigned to
    final userProjects = ref.watch(curUserProjectsListenerProvider);
    return userProjects ?? [];
  }
});
