import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

final searchUsersByNameServiceProvider =
    Provider((ref) => SearchUsersByNameService(ref));

class SearchUsersByNameService {
  final Ref ref;

  SearchUsersByNameService(this.ref);

  Future<List<SearchUserResult>> searchUsers(String searchQuery) async {
    final orgId = ref.read(curSelectedOrgIdNotifierProvider);
    if (orgId == null) return [];

    return await ref.read(usersRepositoryProvider).searchUsersByName(
          searchQuery: searchQuery,
          orgId: orgId,
        );
  }
}
