import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_queries.dart';

final usersByProjectRepositoryProvider =
    Provider<UsersByProjectRepository>((ref) {
  return UsersByProjectRepository(ref.watch(dbProvider));
});

class UsersByProjectRepository extends BaseRepository<UserModel> {
  const UsersByProjectRepository(super.db);

  @override
  Set<String> get watchTables => {'users', 'user_project_assignments'};

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
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
