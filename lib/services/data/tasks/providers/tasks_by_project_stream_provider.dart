import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

final tasksByProjectStreamProvider =
    StreamProvider.family.autoDispose<List<TaskModel>?, String>(
  (ref, projectId) => ref
      .watch(tasksRepositoryProvider)
      .watchTasksByProject(projectId: projectId),
);
