import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_role_comp_list_listener_database_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';

// Top level org provider used by all other providers to get the current org id
final curOrgIdProvider = StateNotifierProvider<CurOrgIdNotifier, String?>((ref) {
  return CurOrgIdNotifier(ref);
});

class CurOrgIdNotifier extends StateNotifier<String?> {
  final Ref ref;

  CurOrgIdNotifier(this.ref) : super(null) {
    _init();
  }

  void _init() {
    ref.listen<List<UserOrgRoleModel>>(curUserOrgRoleCompListListenerDatabaseProvider, (previous, next) {
      final currentOrgId = state;
      final isInCurrentOrg = next.any((orgRole) => orgRole.orgId == currentOrgId);
      
      if (!isInCurrentOrg) {
        setOrgId(null);
      }
    });    
  }

  void setOrgId(String? orgId) {
    state = orgId;
  }

  String? getOrgId() {
    return state;
  }
}