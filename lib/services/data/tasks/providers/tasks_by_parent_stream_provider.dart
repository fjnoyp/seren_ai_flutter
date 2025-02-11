import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

final tasksByParentStreamProvider =
    StreamProvider.family.autoDispose<List<TaskModel>?, String>(
  (ref, parentTaskId) => ref
      .watch(tasksRepositoryProvider)
      .watchChildTasks(parentTaskId: parentTaskId),
);
