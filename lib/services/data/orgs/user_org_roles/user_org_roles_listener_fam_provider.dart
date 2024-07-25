import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/common/base_cacher_db.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

final userOrgRolesListenerFamProvider = NotifierProvider.family<
    UserOrgRolesListenerFamNotifier,
    List<UserOrgRoleModel>?,
    String>(UserOrgRolesListenerFamNotifier.new);

class UserOrgRolesListenerFamNotifier
    extends FamilyNotifier<List<UserOrgRoleModel>?, String> {
  UserOrgRolesListenerFamNotifier();

  @override
  List<UserOrgRoleModel>? build(String arg) {
    final orgId = arg;

    final db = ref.read(dbProvider);
    final query = "SELECT * FROM user_org_roles WHERE org_id = '$orgId'";

    db.watch(query).listen((results) {
      List<UserOrgRoleModel> items =
          results.map((e) => UserOrgRoleModel.fromJson(e)).toList();
      state = items;
    });

    return null;
  }
}
