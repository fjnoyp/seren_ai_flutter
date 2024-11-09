import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_by_project_repository.dart';

final usersInProjectProvider =
    StreamProvider.autoDispose.family<List<UserModel>, String>(
  (ref, projectId) {
    return ref.watch(usersByProjectRepositoryProvider).watchUsersInProject(
          projectId: projectId,
        );
  },
);
