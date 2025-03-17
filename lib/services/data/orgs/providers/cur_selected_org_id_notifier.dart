import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org_local_key.dart';
import 'package:seren_ai_flutter/common/shared_preferences_service_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';
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

  // currently not used
  Future<void> createNewOrg() async {
    try {
      final newOrg = OrgModel(
        name: 'New Org',
        address: '',
      );

      await ref.read(orgsRepositoryProvider).upsertItem(newOrg);

      setDesiredOrgId(newOrg.id);
    } catch (_, __) {
      throw Exception('Failed to create new org');
    }
  }

  Future<void> disableOrgAndRemoveAllRoles() async {
    if (state == null) return;

    // Use a single RPC call to handle both operations atomically
    await ref.read(orgsRepositoryProvider).disableOrgAndRemoveAllRoles(state!);

    // Add a small delay to allow database sync to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Early clear the current selected org id
    // to avoid the 'You're trying to access an organization you are not a member of.' snackbar
    await ref
        .read(curSelectedOrgIdNotifierProvider.notifier)
        .clearDesiredOrgId();
    // Force refresh the user's orgs list to ensure up-to-date data
    ref.invalidate(curUserOrgsProvider);
  }
}
