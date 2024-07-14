import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/joined_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/joined_cur_user_org_roles_comp_provider.dart';

final isCurOrgAdminCompListenerProvider = Provider<bool>((ref) {
  final curOrgId = ref.watch(curOrgIdProvider);
  final List<JoinedOrgRoleModel>? curUserOrgRoles = ref.watch(joinedCurUserOrgRolesCompProvider);

  if (curUserOrgRoles != null) {
    final isCurOrgAdmin = curUserOrgRoles.any((element) => element.orgRole.orgId == curOrgId && element.orgRole.orgRole == 'admin');
    return isCurOrgAdmin;
  }
  return false;
});
