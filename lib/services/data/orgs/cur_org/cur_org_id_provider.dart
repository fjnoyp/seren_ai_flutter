import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_roles_listener_provider.dart';

import 'package:logging/logging.dart';

final log = Logger('CurOrgIdProvider');

final curOrgIdProvider =
    NotifierProvider<CurOrgIdNotifier, String?>(() {
  return CurOrgIdNotifier();
});

class CurOrgIdNotifier extends Notifier<String?> {
  static const String _orgIdKey = 'current_org_id';

  @override
  String? build() {
    _loadSavedOrgId();

    ref.listen(curUserOrgRolesListenerProvider, (previous, next) {
      if (next != null) {
        final currentOrgId = state;
        final isInCurrentOrg = next.any((orgRole) => orgRole.orgId == currentOrgId);

        if (!isInCurrentOrg) {
          // print out what happened 
          log.info('CurOrgId - User left org $currentOrgId');
          log.info('CurOrgId - New orgs: ${next.map((orgRole) => orgRole.orgId).toList()}');
          _setAndSaveOrgId(null);
        }
      } else {
        _setAndSaveOrgId(null);
      }
    }, fireImmediately: true);

    return null;
  }

  Future<void> _loadSavedOrgId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrgId = prefs.getString(_orgIdKey);
    if (savedOrgId != null) {
      state = savedOrgId;
    }
  }

  Future<void> _setAndSaveOrgId(String? orgId) async {
    state = orgId;
    final prefs = await SharedPreferences.getInstance();
    if (orgId != null) {
      await prefs.setString(_orgIdKey, orgId);
    } else {
      await prefs.remove(_orgIdKey);
    }
  }

  void setOrgId(String orgId) {
    _setAndSaveOrgId(orgId);
  }
}