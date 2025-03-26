import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_queries.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Stream<List<UserModel>> watchTaskAssignedUsers({
    required String taskId,
  }) {
    return watch(
      UserQueries.getTaskAssignedUsersQuery,
      {'task_id': taskId},
      triggerOnTables: {
        'users',
        'task_user_assignments',
      },
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

  Future<List<String>> getTaskAssignedUserIds({
    required String taskId,
  }) async {
    final result = await db.execute(
      UserQueries.getTaskAssignedUserIdsQuery,
      [taskId],
    );

    return result.map((row) => row['id'] as String).toList();
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
      triggerOnTables: {
        'users',
        'user_project_assignments',
        'user_team_assignments',
        'team_project_assignments',
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

  Future<List<SearchUserResult>> searchUsersByName({
    required String searchQuery,
    required String orgId,
  }) async {
    final response = await Supabase.instance.client.rpc(
      'search_users_by_name',
      params: {
        'search_query': searchQuery,
        'search_org_id': orgId,
      },
    ) as List<dynamic>;

    return response
        .map((json) => SearchUserResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class SearchUserResult {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final double similarityScore;

  SearchUserResult({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.similarityScore,
  });

  factory SearchUserResult.fromJson(Map<String, dynamic> json) {
    return SearchUserResult(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      similarityScore: json['similarity_score'],
    );
  }
}
