import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final taskUserAssignmentRepositoryProvider =
    Provider<TaskUserAssignmentsRepository>((ref) {
  return TaskUserAssignmentsRepository(ref.watch(dbProvider));
});

class TaskUserAssignmentsRepository
    extends BaseRepository<TaskUserAssignmentsModel> {
  const TaskUserAssignmentsRepository(super.db);

  @override
  Set<String> get watchTables => {'task_user_assignments'};

  @override
  TaskUserAssignmentsModel fromJson(Map<String, dynamic> json) {
    return TaskUserAssignmentsModel.fromJson(json);
  }

  Stream<List<TaskUserAssignmentsModel>> watchUserTaskAssignments({
    required String userId,
  }) {
    return watch(
      TaskQueries.userTaskAssignmentsQuery,
      {
        'user_id': userId,
      },
    );
  }

  Future<List<TaskUserAssignmentsModel>> getUserTaskAssignments({
    required String userId,
  }) async {
    return get(
      TaskQueries.userTaskAssignmentsQuery,
      {
        'user_id': userId,
      },
    );
  }
}
