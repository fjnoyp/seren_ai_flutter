import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_queries.dart';

final userInvitesRepositoryProvider = Provider<UserInvitesRepository>((ref) {
  return UserInvitesRepository(ref.watch(dbProvider));
});

class UserInvitesRepository extends BaseRepository<InviteModel> {
  const UserInvitesRepository(super.db);

  @override
  Set<String> get watchTables => {'invites', 'orgs', 'users'};

  @override
  InviteModel fromJson(Map<String, dynamic> json) {
    return InviteModel.fromJson(json);
  }

  Stream<List<InviteModel>> watchPendingInvitesByEmail({
    required String userEmail,
  }) {
    return watch(
      UserQueries.pendingInvitesByEmailQuery,
      {'user_email': userEmail},
    );
  }

  Future<List<InviteModel>> getPendingInvitesByEmail({
    required String userEmail,
  }) async {
    return get(
      UserQueries.pendingInvitesByEmailQuery,
      {'user_email': userEmail},
    );
  }
}
