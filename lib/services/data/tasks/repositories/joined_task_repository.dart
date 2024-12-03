import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final joinedTasksRepositoryProvider = Provider<JoinedTasksRepository>((ref) {
  return JoinedTasksRepository(ref.watch(dbProvider));
});

class JoinedTasksRepository extends BaseRepository<JoinedTaskModel> {
  const JoinedTasksRepository(super.db);

  @override
  Set<String> get watchTables =>
      {'tasks', 'users', 'projects', 'task_user_assignments', 'task_comments'};

  @override
  JoinedTaskModel fromJson(Map<String, dynamic> json) {
    final decodedJson = json.map((key, value) => [
              'task',
              'author_user',
              'project',
              'assignees',
              'comments',
              'reminder'
            ].contains(key) &&
            value != null
        ? MapEntry(key, jsonDecode(value))
        : MapEntry(key, value));

    return JoinedTaskModel.fromJson(decodedJson);
  }

  Stream<List<JoinedTaskModel>> watchUserViewableJoinedTasks(String userId) {
    return watch(
      TaskQueries.userViewableJoinedTasksQuery,
      {'user_id': userId},
    );
  }

  Future<List<JoinedTaskModel>> getUserViewableJoinedTasks(
      String userId) async {
    return get(
      TaskQueries.userViewableJoinedTasksQuery,
      {'user_id': userId},
    );
  }

  Stream<List<JoinedTaskModel>> watchUserAssignedJoinedTasks(String userId) {
    return watch(
      TaskQueries.userAssignedJoinedTasksQuery,
      {'user_id': userId},
    );
  }

  Future<List<JoinedTaskModel>> getUserAssignedJoinedTasks(
      String userId) async {
    return get(
      TaskQueries.userAssignedJoinedTasksQuery,
      {'user_id': userId},
    );
  }

  Future<JoinedTaskModel?> getJoinedTaskById(String taskId) async {
    final results = await get(
      TaskQueries.joinedTaskByIdQuery,
      {'task_id': taskId},
    );
    return results.isEmpty ? null : results.first;
  }
}
