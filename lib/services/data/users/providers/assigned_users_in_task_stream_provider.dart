import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final assignedUsersInTaskStreamProvider =
    StreamProvider.family<List<UserModel>, String>(
  (ref, taskId) =>
      ref.watch(usersRepositoryProvider).watchTaskAssignedUsers(taskId: taskId),
);
