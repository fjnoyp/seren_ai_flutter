import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/org_queries.dart';

final orgsRepositoryProvider = Provider<OrgsRepository>((ref) {
  return OrgsRepository(ref.watch(dbProvider));
});

class OrgsRepository extends BaseRepository<OrgModel> {
  const OrgsRepository(super.db);

  @override
  Set<String> get REMOVEwatchTables => {'orgs'};

  @override
  OrgModel fromJson(Map<String, dynamic> json) {
    return OrgModel.fromJson(json);
  }

  Stream<List<OrgModel>> watchUserOrgs({
    required String userId,
  }) {
    return watch(
      OrgQueries.userOrgsQuery,
      {
        'user_id': userId,
      },
    );
  }

  Future<List<OrgModel>> getUserOrgs({
    required String userId,
  }) async {
    return get(
      OrgQueries.userOrgsQuery,
      {
        'user_id': userId,
      },
    );
  }
}
