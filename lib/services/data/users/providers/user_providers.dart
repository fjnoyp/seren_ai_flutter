import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final userProvider = StreamProvider.autoDispose.family<UserModel?, String>(
  (ref, userId) {
    return ref.watch(usersRepositoryProvider).watchUser(
          userId: userId,
        );
  },
);

final userListProvider = StreamProvider.autoDispose.family<List<UserModel>, List<String>>(
  (ref, userIds) {
    return ref.watch(usersRepositoryProvider).watchUsers(
          userIds: userIds,
        );
  },
);
