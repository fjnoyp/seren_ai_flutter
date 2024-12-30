import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/joined_project_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/project_queries.dart';

final joinedProjectsRepositoryProvider =
    Provider<JoinedProjectsRepository>((ref) {
  return JoinedProjectsRepository(ref.watch(dbProvider));
});

class JoinedProjectsRepository extends BaseRepository<JoinedProjectModel> {
  const JoinedProjectsRepository(super.db);

  @override
  Set<String> get watchTables => {'projects', 'orgs', 'users'};

  @override
  JoinedProjectModel fromJson(Map<String, dynamic> json) {
    final decodedJson = json.map((key, value) =>
        (key == 'project' || key == 'org' || key == 'assignees') &&
                value != null
            ? MapEntry(key, jsonDecode(value))
            : MapEntry(key, value));

    return JoinedProjectModel.fromJson(decodedJson);
  }

  Stream<List<JoinedProjectModel>> watchOrgProjects(String orgId) {
    return watch(
      ProjectQueries.joinedOrgProjectsQuery,
      {'org_id': orgId},
    );
  }

  Future<List<JoinedProjectModel>> getOrgProjects(String orgId) async {
    return get(
      ProjectQueries.joinedOrgProjectsQuery,
      {'org_id': orgId},
    );
  }

  Stream<JoinedProjectModel> watchJoinedProjectById(String projectId) {
    return watchSingle(
      ProjectQueries.joinedProjectByIdQuery,
      {'project_id': projectId},
    );
  }

  Future<JoinedProjectModel> getJoinedProjectById(String projectId) async {
    return getSingle(
      ProjectQueries.joinedProjectByIdQuery,
      {'project_id': projectId},
    );
  }
}
