import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_comments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_repository.dart';

final taskCommentsProvider = StreamProvider.autoDispose<List<TaskCommentsModel>?>((ref) {
  return CurTaskDependencyProvider.watchStream(
    ref: ref,
    builder: (task) => ref
        .watch(taskCommentsRepositoryProvider)
        .watchTaskComments(taskId: task.task.id),
  );
});

final joinedTaskCommentsProvider =
    StreamProvider.autoDispose<List<JoinedTaskCommentsModel>?>((ref) {
  return CurTaskDependencyProvider.watchStream(
    ref: ref,
    builder: (task) => ref
        .watch(joinedTaskCommentsRepositoryProvider)
        .watchJoinedTaskComments(task.task.id),
  );
});
