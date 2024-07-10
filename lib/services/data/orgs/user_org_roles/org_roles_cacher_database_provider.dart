import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/base_cacher_database_notifier.dart';

final userOrgRolesCacherDatabaseProvider = Provider.family<BaseLoaderCacheDatabaseNotifier<UserOrgRoleModel>, String>((ref, orgId) {
  return BaseLoaderCacheDatabaseNotifier<UserOrgRoleModel>(
    tableName: 'user_org_roles',
    fromJson: (json) => UserOrgRoleModel.fromJson(json),
    toJson: (item) => item.toJson(),
  );
});

/*
Need:

  Future<void> _loadData(String orgId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('org_id', orgId);

    final data = response as List<dynamic>;
    final userOrgRoles = data.map((json) => fromJson(json)).toList();
    state = userOrgRoles;
  }
  */