import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/z_base_table_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';

final userOrgRolesDbProvider = Provider<BaseTableDb<UserOrgRoleModel>>((ref) {
  return BaseTableDb<UserOrgRoleModel>(
    db: ref.watch(dbProvider),
    tableName: 'user_org_roles',
    fromJson: (json) => UserOrgRoleModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});
