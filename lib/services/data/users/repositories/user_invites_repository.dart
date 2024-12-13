import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/joined_invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_queries.dart';

final userInvitesRepositoryProvider = Provider<UserInvitesRepository>((ref) {
  return UserInvitesRepository(ref.watch(dbProvider));
});

class UserInvitesRepository extends BaseRepository<JoinedInviteModel> {
  const UserInvitesRepository(super.db);

  @override
  Set<String> get watchTables => {'invites', 'orgs', 'users'};

  @override
  JoinedInviteModel fromJson(Map<String, dynamic> json) {
    final decodedJson = json.map((key, value) => [
              'invite',
              'org',
              'author_user',
            ].contains(key) &&
            value != null
        ? MapEntry(key, jsonDecode(value))
        : MapEntry(key, value));

    return JoinedInviteModel.fromJson(decodedJson);
  }

  Stream<List<JoinedInviteModel>> watchPendingInvitesByEmail({
    required String userId,
  }) {
    return watch(
      UserQueries.pendingInvitesByEmailQuery,
      {'user_id': userId},
    );
  }

  Future<List<JoinedInviteModel>> getPendingInvitesByEmail({
    required String userId,
  }) async {
    return get(
      UserQueries.pendingInvitesByEmailQuery,
      {'user_id': userId},
    );
  }
}
