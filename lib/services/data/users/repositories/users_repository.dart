import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_queries.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(dbProvider));
});

class UsersRepository extends BaseRepository<UserModel> {
  const UsersRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'users'};

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  // Watch a specific user by ID
  Stream<UserModel?> watchUser({
    required String userId,
  }) {
    return watchSingle(UserQueries.userByIdQuery, {'user_id': userId});
  }

  // Get a specific user by ID
  Future<UserModel?> getUser({
    required String userId,
  }) async {
    return getSingle(UserQueries.userByIdQuery, {'user_id': userId});
  }

  // Watch specific users by their IDs
  Stream<List<UserModel>> watchUsers({
    required List<String> userIds,
  }) {
    return watch(UserQueries.usersByIdQuery, {'user_ids': userIds});
  }

  // Get specific users by their IDs
  Future<List<UserModel>> getUsers({
    required List<String> userIds,
  }) async {
    return get(UserQueries.usersByIdQuery, {'user_ids': userIds});
  }

  Stream<List<UserModel>> watchTaskAssigneeUsers({
    required String taskId,
  }) {
    return watch(
      UserQueries.taskAssigneeUsersQuery,
      {'task_id': taskId},
    );
  }
}
