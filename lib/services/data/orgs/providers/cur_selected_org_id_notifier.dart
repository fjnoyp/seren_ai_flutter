import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org_local_key.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';

final curSelectedOrgProvider = StreamProvider<OrgModel?>((ref) {
  final orgId = ref.watch(curSelectedOrgIdNotifierProvider);
  if (orgId == null) return Stream.value(null);

  final orgsRepo = ref.read(orgsRepositoryProvider);
  return orgsRepo.watchById(orgId);
});

final curSelectedOrgIdNotifierProvider =
    NotifierProvider<CurSelectedOrgIdNotifier, String?>(() {
  return CurSelectedOrgIdNotifier();
});

class CurSelectedOrgIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    return prefs.getString(orgIdKey);
  }

  Future<void> setDesiredOrgId(String desiredOrgId) async {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.setString(orgIdKey, desiredOrgId);
    ref.invalidateSelf();
  }

  Future<void> clearDesiredOrgId() async {
    final prefs = ref.read(sharedPreferencesServiceProvider);
    await prefs.remove(orgIdKey);
    ref.invalidateSelf();
  }
}
