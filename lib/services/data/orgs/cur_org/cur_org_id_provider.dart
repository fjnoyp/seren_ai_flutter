import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_list_listener_database_provider.dart';

final curOrgIdProvider =
    StateNotifierProvider<CurOrgIdNotifier, String?>((ref) {
  return CurOrgIdNotifier(ref);
});

class CurOrgIdNotifier extends StateNotifier<String?> {
  final Ref ref;

  CurOrgIdNotifier(this.ref) : super(null) {
    _init();
  }

  void _init() {
    ref.listen(curUserOrgRolesListListenerDatabaseProvider, (previous, next) {
      if (next != null) {
        final currentOrgId = state;
        final isInCurrentOrg = next.any((orgRole) => orgRole.orgId == currentOrgId);

        if (!isInCurrentOrg) {
          state = null;
        }
      } else {
        state = null;
      }
    }, fireImmediately: true);
  }

  void setOrgId(String orgId) {
    state = orgId;
  }
}
