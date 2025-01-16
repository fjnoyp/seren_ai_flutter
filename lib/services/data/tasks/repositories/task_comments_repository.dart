import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final taskCommentsRepositoryProvider = Provider<TaskCommentsRepository>((ref) {
  return TaskCommentsRepository(ref.watch(dbProvider));
});

class TaskCommentsRepository extends BaseRepository<TaskCommentModel> {
  const TaskCommentsRepository(super.db,
      {super.primaryTable = 'task_comments'});

  @override
  TaskCommentModel fromJson(Map<String, dynamic> json) {
    return TaskCommentModel.fromJson(json);
  }

  Stream<List<TaskCommentModel>> watchTaskComments({
    required String taskId,
  }) {
    return watch(
      TaskQueries.taskCommentsQuery,
      {
        'task_id': taskId,
      },
    );
  }

  Future<List<TaskCommentModel>> getTaskComments({
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
