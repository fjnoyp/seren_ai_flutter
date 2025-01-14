import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

// Load related task data for displaying in a list

// Actually we just need this one, which I think could be used for both
// the task list and the task page, if we turn it into a stream provider...

final taskAssigneesProvider = FutureProvider.autoDispose
    .family<List<UserModel>, TaskModel>((ref, task) async {
  return await ref
      .read(usersRepositoryProvider)
      .getTaskAssignedUsers(taskId: task.id);
});
