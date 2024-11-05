import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_id_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';

final isCurUserOrgAdminListenerProvider = Provider<bool>((ref) {
  final curOrgId = ref.watch(curUserOrgIdProvider);
  final List<UserOrgRoleModel>? curUserOrgRoles = ref.watch(curUserOrgRolesListenerProvider);

  if (curUserOrgRoles != null) {
    final isCurOrgAdmin = curUserOrgRoles.any((element) => element.orgId == curOrgId && element.orgRole == 'admin');
    return isCurOrgAdmin;
  }
  return false;
});
