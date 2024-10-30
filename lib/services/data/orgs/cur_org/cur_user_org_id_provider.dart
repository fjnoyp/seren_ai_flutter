import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_listener_provider.dart';

import 'package:logging/logging.dart';

final log = Logger('CurOrgIdProvider');

final curUserOrgIdProvider =
    NotifierProvider<CurUserOrgIdNotifier, String?>(() {
  return CurUserOrgIdNotifier();
});

class CurUserOrgIdNotifier extends Notifier<String?> {
  static const String _orgIdKey = 'current_org_id';

  @override
  String? build() {
    state = _getDesiredOrgId();

    ref.listen(curUserOrgRolesListenerProvider, (previous, next) {
      if (next != null) {        
        final desiredOrgId = _getDesiredOrgId();

        final orgIds = next.map((orgRole) => orgRole.orgId).toList();

        if(orgIds.contains(desiredOrgId)) {
          state = desiredOrgId;
        }
        else{
          state = null; 
        }
      } else {
        state = null;
      }
    }, fireImmediately: true);

    return null; 
  }

  String? _getDesiredOrgId() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_orgIdKey);
  }

  // We assume desiredOrgId is valid for user ... 
  void setDesiredOrgId(String desiredOrgId) {
    state = desiredOrgId;
    final prefs = ref.read(sharedPreferencesProvider);
    if (desiredOrgId != null) {
      prefs.setString(_orgIdKey, desiredOrgId);
    } else {
      prefs.remove(_orgIdKey);
    }
  }
}