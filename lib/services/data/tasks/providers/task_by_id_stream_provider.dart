import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

final taskByIdStreamProvider =
    StreamProvider.autoDispose.family<TaskModel?, String>((ref, taskId) {
  final tasksRepo = ref.read(tasksRepositoryProvider);
  return tasksRepo.watchById(taskId);
});
