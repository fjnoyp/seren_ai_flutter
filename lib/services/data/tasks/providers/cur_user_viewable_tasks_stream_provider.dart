import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final curUserViewableTasksStreamProvider =
    StreamProvider.autoDispose<List<TaskModel>?>(
  (ref) {
    final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (curOrgId == null) throw Exception('No org selected');

    return CurAuthDependencyProvider.watchStream(
      ref: ref,
      builder: (userId) => ref
          .watch(tasksRepositoryProvider)
          .watchUserViewableTasks(userId: userId, orgId: curOrgId),
    );
  },
);

/// The tasks are ordered by:
/// 1. Whether the task is in the user's default project
/// 2. Whether the task has a due date
/// 3. The due date
/// 4. The priority
final curUserSortedTasksStreamProvider =
    StreamProvider.autoDispose<List<TaskModel>?>((ref) {
  final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
  final curUserAsync = ref.watch(curUserProvider);
  if (curOrgId == null) throw Exception('No org selected');

  return CurAuthDependencyProvider.watchStream(
    ref: ref,
    builder: (userId) {
      final viewableTasks = ref
          .watch(tasksRepositoryProvider)
          .watchUserViewableTasks(userId: userId, orgId: curOrgId);

      final filteredTasks = viewableTasks.map((tasks) => tasks
          .where((task) => (task.status == StatusEnum.open ||
              task.status == StatusEnum.inProgress))
          .toList());

      filteredTasks.map((tasks) {
        tasks.sort((a, b) {
          // Sort by whether task has due date (tasks with due dates come first)
          if (a.dueDate != null && b.dueDate == null) return -1;
          if (a.dueDate == null && b.dueDate != null) return 1;

          // If both have due dates, sort by due date
          if (a.dueDate != null && b.dueDate != null) {
            final dateComparison = a.dueDate!.compareTo(b.dueDate!);
            if (dateComparison != 0) return dateComparison;
          }

          // Sort by priority (higher priority comes first)
          return b.priority?.toInt().compareTo(a.priority?.toInt() ?? 0) ?? 0;
        });
        return tasks;
      });

      // Sort by whether task is in the user's default project
      // when curUser is not null
      if (curUserAsync.value case UserModel curUser) {
        return filteredTasks.map((tasks) {
          tasks.sort((a, b) {
            final aIsDefaultProject =
                a.parentProjectId == curUser.defaultProjectId;
            final bIsDefaultProject =
                b.parentProjectId == curUser.defaultProjectId;
            if (aIsDefaultProject && !bIsDefaultProject) return -1;
            if (!aIsDefaultProject && bIsDefaultProject) return 1;
            return 0;
          });
          return tasks;
        });
      }

      return filteredTasks;
    },
  );
});
