import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

// Not sure if this provider should be here,
// just following the pattern of the "users in project" provider
final usersInTaskStreamProvider = StreamProvider.family<List<UserModel>, String>(
  (ref, taskId) => ref
      .watch(usersRepositoryProvider)
      .watchTaskAssignedUsers(taskId: taskId),
);
