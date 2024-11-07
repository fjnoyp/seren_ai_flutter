import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

final curUserViewableTasksProvider =
    StreamProvider.autoDispose<List<TaskModel>?>(
  (ref) {
    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) => ref
          .watch(tasksRepositoryProvider)
          .watchUserViewableTasks(userId: userId),
    );
  },
);

final joinedCurUserViewableTasksProvider =
    StreamProvider.autoDispose<List<JoinedTaskModel>?>(
  (ref) {
    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) => ref
          .watch(joinedTasksRepositoryProvider)
          .watchUserViewableJoinedTasks(userId),
    );
  },
);
