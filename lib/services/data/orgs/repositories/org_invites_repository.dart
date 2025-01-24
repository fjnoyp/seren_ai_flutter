import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/org_queries.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';

final orgInvitesRepositoryProvider = Provider<OrgInvitesRepository>((ref) {
  return OrgInvitesRepository(ref.watch(dbProvider));
});

class OrgInvitesRepository extends BaseRepository<InviteModel> {
  const OrgInvitesRepository(super.db, {super.primaryTable = 'invites'});

  @override
  InviteModel fromJson(Map<String, dynamic> json) {
    return InviteModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(InviteModel item) {
    return item.toJson();
  }

  Stream<List<InviteModel>> watchPendingInvitesByOrg({
    required String orgId,
  }) {
    print('watchPendingInvitesByOrg called with orgId: $orgId');
    return watch(
      OrgQueries.pendingInvitesByOrgQuery,
      {'org_id': orgId},
    );
  }

  Future<List<InviteModel>> getPendingInvitesByOrg({
    required String orgId,
  }) async {
    return get(
      OrgQueries.pendingInvitesByOrgQuery,
      {'org_id': orgId},
    );
  }
}
