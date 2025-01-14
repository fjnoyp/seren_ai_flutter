import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignment_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final taskUserAssignmentsRepositoryProvider =
    Provider<TaskUserAssignmentsRepository>((ref) {
  return TaskUserAssignmentsRepository(ref.watch(dbProvider));
});

class TaskUserAssignmentsRepository
    extends BaseRepository<TaskUserAssignmentModel> {
  const TaskUserAssignmentsRepository(super.db,
      {super.primaryTable = 'task_user_assignments'});

  @override
  TaskUserAssignmentModel fromJson(Map<String, dynamic> json) {
    return TaskUserAssignmentModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(TaskUserAssignmentModel item) {
    return item.toJson();
  }

  Stream<List<TaskUserAssignmentModel>> watchTaskAssignments({
    required String taskId,
  }) {
    return watch(
      TaskQueries.getTaskUserAssignmentsQuery,
      {
        'task_id': taskId,
      },
    );
  }

  Future<List<TaskUserAssignmentModel>> getTaskAssignments({
    required String taskId,
  }) async {
    return get(
      TaskQueries.getTaskUserAssignmentsQuery,
      {
        'task_id': taskId,
      },
    );
  }

  Future<String?> getTaskAssignmentId({
    required String taskId,
    required String userId,
  }) async {
    return getSingle(
      TaskQueries.getTaskUserAssignmentIdQuery,
      {
        'task_id': taskId,
        'user_id': userId,
      },
    ).then((result) => result.id);
  }
}
