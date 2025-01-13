import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_queries.dart';

final usersInProjectProvider = StreamProvider.family<List<UserModel>, String>(
  (ref, projectId) => ref
      .watch(usersRepositoryProvider)
      .watchUsersInProject(projectId: projectId),
);

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(dbProvider));
});

class UsersRepository extends BaseRepository<UserModel> {
  const UsersRepository(super.db, {super.primaryTable = 'users'});

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(UserModel item) {
    return item.toJson();
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

  Future<List<UserModel>> getTaskAssignedUsers({
    required String taskId,
  }) async {
    return get(
      UserQueries.getTaskAssignedUsersQuery,
      {
        'task_id': taskId,
      },
    );
  }

  // Watch users assigned to a specific project
  Stream<List<UserModel>> watchUsersInProject({
    required String projectId,
  }) {
    return watch(
      UserQueries.usersInProjectQuery,
      {
        'project_id': projectId,
      },
    );
  }

  // Get users assigned to a specific project
  Future<List<UserModel>> getUsersInProject({
    required String projectId,
  }) async {
    return await get(
      UserQueries.usersInProjectQuery,
      {
        'project_id': projectId,
      },
    );
  }
}
