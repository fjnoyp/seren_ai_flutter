import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/user_project_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/project_queries.dart';

final userProjectAssignmentsRepositoryProvider =
    Provider<UserProjectAssignmentsRepository>((ref) {
  return UserProjectAssignmentsRepository(ref.watch(dbProvider));
});

class UserProjectAssignmentsRepository
    extends BaseRepository<UserProjectAssignmentModel> {
  const UserProjectAssignmentsRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'user_project_assignments'};

  @override
  UserProjectAssignmentModel fromJson(Map<String, dynamic> json) {
    return UserProjectAssignmentModel.fromJson(json);
  }

  Stream<List<UserProjectAssignmentModel>> watchUserProjectAssignments({
    required String projectId,
  }) {
    return watch(
      ProjectQueries.userProjectAssignmentsQuery,
      {
        'project_id': projectId,
      },
    );
  }

  Future<List<UserProjectAssignmentModel>> getUserProjectAssignments({
    required String projectId,
  }) async {
    return get(
      ProjectQueries.userProjectAssignmentsQuery,
      {
        'project_id': projectId,
      },
    );
  }
}
