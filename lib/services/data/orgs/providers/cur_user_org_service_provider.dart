// ignore_for_file: unused_result

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org_local_key.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';

final curUserOrgServiceProvider = Provider<CurUserOrgService>((ref) {
  return CurUserOrgService(ref);
});

class CurUserOrgService {
  final Ref ref;

  CurUserOrgService(this.ref);

  Future<void> setDesiredOrgId(String desiredOrgId) async {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.setString(orgIdKey, desiredOrgId);
    ref.refresh(curOrgIdProvider);
  }

  Future<void> clearDesiredOrgId() async {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.remove(orgIdKey);
    ref.refresh(curOrgIdProvider);
  }
}
