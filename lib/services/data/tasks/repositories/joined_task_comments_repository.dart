import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final joinedTaskCommentsRepositoryProvider =
    Provider<JoinedTaskCommentsRepository>((ref) {
  return JoinedTaskCommentsRepository(ref.watch(dbProvider));
});

class JoinedTaskCommentsRepository
    extends BaseRepository<JoinedTaskCommentsModel> {
  const JoinedTaskCommentsRepository(super.db);

  @override
  Set<String> get watchTables => {'task_comments', 'users', 'tasks'};

  @override
  JoinedTaskCommentsModel fromJson(Map<String, dynamic> json) {
    return JoinedTaskCommentsModel.fromJson(json);
  }

  Stream<List<JoinedTaskCommentsModel>> watchJoinedTaskComments(String taskId) {
    return watch(
      TaskQueries.joinedTaskCommentsQuery,
      {'task_id': taskId},
    );
  }

  Future<List<JoinedTaskCommentsModel>> getJoinedTaskComments(
      String taskId) async {
    return get(
      TaskQueries.joinedTaskCommentsQuery,
      {'task_id': taskId},
    );
  }
}
