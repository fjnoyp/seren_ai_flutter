import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

/// Stream provider that watches tasks directly assigned to the current user
final curUserTasksStreamProvider =
    StreamProvider.autoDispose<List<TaskModel>>((ref) {
  final userAsync = ref.watch(curUserProvider);
  final orgId = ref.watch(curSelectedOrgIdNotifierProvider);
  final user = userAsync.valueOrNull;

  if (user == null || orgId == null) {
    return Stream.value([]);
  }

  return ref
      .watch(tasksRepositoryProvider)
      .watchUserAssignedTasks(userId: user.id, orgId: orgId);
});
