import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_dependency_provider.dart';

final curUserOrgsProvider = StreamProvider.autoDispose<List<OrgModel>>((ref) {
  return CurAuthDependencyProvider.watchStream<List<OrgModel>>(
    ref: ref,
    builder: (userId) {
      return ref.watch(orgsRepositoryProvider).watchUserOrgs(userId: userId);
    },
  );
});
