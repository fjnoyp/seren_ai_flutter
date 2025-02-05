import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

final usersInProjectProvider =
    StreamProvider.autoDispose.family<List<UserModel>, String>(
  (ref, projectId) => ref
      .watch(usersRepositoryProvider)
      .watchUsersInProject(projectId: projectId),
);
