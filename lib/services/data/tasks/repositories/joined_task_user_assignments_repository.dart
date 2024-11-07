import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final joinedTaskUserAssignmentsRepositoryProvider = Provider<JoinedTaskUserAssignmentsRepository>((ref) {
  return JoinedTaskUserAssignmentsRepository(ref.watch(dbProvider));
});

class JoinedTaskUserAssignmentsRepository extends BaseRepository<JoinedTaskUserAssignmentsModel> {
  const JoinedTaskUserAssignmentsRepository(super.db);

  @override
  Set<String> get watchTables => {'task_user_assignments', 'users', 'tasks'};

  @override
  JoinedTaskUserAssignmentsModel fromJson(Map<String, dynamic> json) {
    return JoinedTaskUserAssignmentsModel.fromJson(json);
  }

  Stream<List<JoinedTaskUserAssignmentsModel>> watchJoinedTaskAssignments(String taskId) {
    return watch(
      TaskQueries.joinedTaskUserAssignmentsQuery,
      {'task_id': taskId},
    );
  }

  Future<List<JoinedTaskUserAssignmentsModel>> getJoinedTaskAssignments(String taskId) async {
    return get(
      TaskQueries.joinedTaskUserAssignmentsQuery,
      {'task_id': taskId},
    );
  }

  Stream<List<JoinedTaskUserAssignmentsModel>> watchUserTaskAssignments(String userId) {
    return watch(
      TaskQueries.joinedTaskUserAssignmentsByUserQuery,
      {'user_id': userId},
    );
  }

  Future<List<JoinedTaskUserAssignmentsModel>> getUserTaskAssignments(String userId) async {
    return get(
      TaskQueries.joinedTaskUserAssignmentsByUserQuery,
      {'user_id': userId},
    );
  }
} 