import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_queries.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(dbProvider));
});

class TasksRepository extends BaseRepository<TaskModel> {
  const TasksRepository(super.db);

  @override
  Set<String> get watchTables => {'tasks', 'projects'};

  @override
  TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel.fromJson(json);
  }

  // Watch viewable tasks for a user (tasks where they are assigned to the project or are the author)
  Stream<List<TaskModel>> watchUserViewableTasks({
    required String userId,
  }) {
    return watch(
      TaskQueries.userViewableTasksQuery,
      {
        'user_id': userId,
        'author_user_id': userId,
      },
    );
  }

  // TODO p2: introduce pagination once we have a lot of tasks
  // Get viewable tasks for a user (tasks where they are assigned to the project or are the author)
  Future<List<TaskModel>> getUserViewableTasks({
    required String userId,
  }) async {
    return get(
      TaskQueries.userViewableTasksQuery,
      {
        'user_id': userId,
        'author_user_id': userId,
      },
    );
  }

  // Watch assigned tasks for a user (tasks where they are assigned to the task directly)
  Stream<List<TaskModel>> watchUserAssignedTasks({required String userId}) {
    return watch(
      TaskQueries.userAssignedTasksQuery,
      {'user_id': userId},
    );
  }

  // Get assigned tasks for a user (tasks where they are assigned to the task directly)
  Future<List<TaskModel>> getUserAssignedTasks({required String userId}) async {
    return get(
      TaskQueries.userAssignedTasksQuery,
      {'user_id': userId},
    );
  }
}
