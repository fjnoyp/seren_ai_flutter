import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_listener_provider.dart';

final curOrgIdProvider =
    NotifierProvider<CurOrgIdNotifier, String?>(() {
  return CurOrgIdNotifier();
});

class CurOrgIdNotifier extends Notifier<String?> {
  @override
  String? build() {

    ref.listen(curUserOrgRolesListenerProvider, (previous, next) {
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

    return null; 
  }

  CurOrgIdNotifier() : super();

  void setOrgId(String orgId) {
    state = orgId;
  }
}
