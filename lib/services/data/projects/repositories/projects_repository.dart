import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/project_queries.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository(ref.watch(dbProvider));
});

class ProjectsRepository extends BaseRepository<ProjectModel> {
  const ProjectsRepository(super.db);

  @override
  Set<String> get watchTables => {
        'projects',
        'user_project_assignments',
        'team_project_assignments',
        'user_team_assignments'
      };

  @override
  ProjectModel fromJson(Map<String, dynamic> json) {
    return ProjectModel.fromJson(json);
  }

  // Watch projects for a user (projects where they are assigned directly or via teams)
  Stream<List<ProjectModel>> watchUserProjects({
    required String userId,
  }) {
    return watch(ProjectQueries.userViewableProjectsQuery, {'user_id': userId});
  }

  // Get projects for a user (projects where they are assigned directly or via teams)
  Future<List<ProjectModel>> getUserProjects({
    required String userId,
  }) async {
    return get(ProjectQueries.userViewableProjectsQuery, {'user_id': userId});
  }

  // Watch projects for an org
  Stream<List<ProjectModel>> watchOrgProjects({
    required String orgId,
  }) {
    return watch(ProjectQueries.orgProjectsQuery, {'org_id': orgId});
  }

  // Get projects for an org
  Future<List<ProjectModel>> getOrgProjects({
    required String orgId,
  }) async {
    return get(ProjectQueries.orgProjectsQuery, {'org_id': orgId});
  }

  Future<ProjectModel?> getProjectById({
    required String projectId,
  }) async {
    return get(ProjectQueries.projectByIdQuery, {'project_id': projectId})
        .then((projects) => projects.firstOrNull);
  }
}
