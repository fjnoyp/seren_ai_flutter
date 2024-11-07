import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final taskCommentsRepositoryProvider = Provider<TaskCommentsRepository>((ref) {
  return TaskCommentsRepository(ref.watch(dbProvider));
});

class TaskCommentsRepository extends BaseRepository<TaskCommentsModel> {
  const TaskCommentsRepository(super.db);

  @override
  Set<String> get watchTables => {'task_comments'};

  @override
  TaskCommentsModel fromJson(Map<String, dynamic> json) {
    return TaskCommentsModel.fromJson(json);
  }

  Stream<List<TaskCommentsModel>> watchTaskComments({
    required String taskId,
  }) {
    return watch(
      TaskQueries.taskCommentsQuery,
      {
        'task_id': taskId,
      },
    );
  }

  Future<List<TaskCommentsModel>> getTaskComments({
    required String taskId,
  }) async {
    return get(
      TaskQueries.taskCommentsQuery,
      {
        'task_id': taskId,
      },
    );
  }
}
