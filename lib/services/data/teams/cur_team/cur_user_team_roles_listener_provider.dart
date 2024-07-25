import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/teams/models/user_team_role_model.dart';

// Provide all team roles for current user
final curUserTeamRolesListenerProvider = NotifierProvider<CurUserTeamRolesListenerNotifier, List<UserTeamRoleModel>?>(
  CurUserTeamRolesListenerNotifier.new
);

/// Get the current user's team roles
class CurUserTeamRolesListenerNotifier extends Notifier<List<UserTeamRoleModel>?> {

  @override
  List<UserTeamRoleModel>? build() {

    final watchedCurAuthUser = ref.watch(curAuthUserProvider);

    if(watchedCurAuthUser == null) {
      return null;
    }
    
    final db = ref.read(dbProvider);

    final query = "SELECT * FROM user_team_roles WHERE user_id = '${watchedCurAuthUser.id}'";

    db.watch(query).listen((results) {
      List<UserTeamRoleModel> items = results.map((e) => UserTeamRoleModel.fromJson(e)).toList();
      state = items; 
    });

  }  
}
