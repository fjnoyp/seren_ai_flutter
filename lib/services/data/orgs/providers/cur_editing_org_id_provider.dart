import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';

final curEditingOrgIdProvider =
    NotifierProvider<EditingOrgIdNotifier, String?>(() {
  return EditingOrgIdNotifier();
});

class EditingOrgIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  Future<void> setOrgId(String orgId) async {
    state = orgId;
  }

  Future<void> createNewOrg() async {
    try {
      final curUser = ref.read(curUserProvider).value;
      if (curUser == null) throw Exception('No current user');

      final newOrg = OrgModel(
        name: 'New Org',
        address: '',
      );

      await ref.read(orgsRepositoryProvider).upsertItem(newOrg);

      state = newOrg.id;
    } catch (_, __) {
      throw Exception('Failed to create new org');
    }
  }
}
