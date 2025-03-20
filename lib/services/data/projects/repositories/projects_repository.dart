import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/project_queries.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository(ref.watch(dbProvider));
});

class ProjectsRepository extends BaseRepository<ProjectModel> {
  const ProjectsRepository(super.db, {super.primaryTable = 'projects'});

  @override
  ProjectModel fromJson(Map<String, dynamic> json) {
    return ProjectModel.fromJson(json);
  }

  // Watch projects for a user (projects where they are assigned directly or via teams)
  Stream<List<ProjectModel>> watchUserProjects({
    required String userId,
    required String orgId,
  }) {
    return watch(
      ProjectQueries.userViewableProjectsQuery,
      {
        'user_id': userId,
        'org_id': orgId,
      },
      triggerOnTables: {
        'projects',
        'user_project_assignments',
        'team_project_assignments',
        'user_team_assignments',
        'user_org_roles',
      },
    );
  }

  // Get projects for a user (projects where they are assigned directly or via teams)
  Future<List<ProjectModel>> getUserProjects({
    required String userId,
    required String orgId,
  }) async {
    return get(ProjectQueries.userViewableProjectsQuery, {
      'user_id': userId,
      'org_id': orgId,
    });
  }

  Future<void> updateProjectName(String projectId, String name) async {
    if (name.isNotEmpty) {
      await updateField(projectId, 'name', name);
    }
  }

  Future<void> updateProjectDescription(
      String projectId, String description) async {
    await updateField(projectId, 'description', description);
  }

  Future<void> updateProjectAddress(String projectId, String address) async {
    await updateField(projectId, 'address', address);
  }

// TODO p4 - we should just do this locally... since there will never be many projects
  Future<List<SearchProjectResult>> searchProjectsByName({
    required String searchQuery,
    required String orgId,
  }) async {
    final response = await Supabase.instance.client.rpc(
      'search_projects_by_name',
      params: {
        'search_query': searchQuery,
        'search_org_id': orgId,
      },
    ) as List<dynamic>;

    return response
        .map((json) =>
            SearchProjectResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class SearchProjectResult {
  final String id;
  final String name;
  final double similarityScore;

  SearchProjectResult({
    required this.id,
    required this.name,
    required this.similarityScore,
  });

  factory SearchProjectResult.fromJson(Map<String, dynamic> json) {
    return SearchProjectResult(
      id: json['id'],
      name: json['name'],
      similarityScore: json['similarity_score'],
    );
  }
}
