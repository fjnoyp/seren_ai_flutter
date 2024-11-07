import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/joined_task_user_assignments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_user_assignment_repository.dart';

final curUserAssignedTasksProvider =
    StreamProvider.autoDispose<List<TaskUserAssignmentsModel>?>((ref) {
  return CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref
        .watch(taskUserAssignmentRepositoryProvider)
        .watchUserTaskAssignments(userId: userId),
  );
});

final joinedTaskUserAssignmentsProvider =
    StreamProvider.autoDispose<List<JoinedTaskUserAssignmentsModel>?>((ref) {
  return CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) => ref
        .watch(joinedTaskUserAssignmentsRepositoryProvider)
        .watchUserTaskAssignments(userId),
  );
});
