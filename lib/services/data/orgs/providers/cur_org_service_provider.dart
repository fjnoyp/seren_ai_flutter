import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/org_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/orgs_db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';

final curOrgProvider = NotifierProvider<CurOrgStateNotifier, OrgModel>(
  () => CurOrgStateNotifier(),
);

class CurOrgStateNotifier extends Notifier<OrgModel> {
  @override
  OrgModel build() {
    final curOrg = ref
        .watch(curUserOrgsProvider)
        .value
        ?.firstWhere((org) => org.id == ref.watch(curOrgIdProvider));

    if (curOrg == null) {
      throw Exception('No current organization found');
    }

    return curOrg;
  }

  String get curOrgId => state.id;

  bool isValidOrg() => state.name.isNotEmpty;

  void updateOrgName(String name) => state = state.copyWith(name: name);

  void updateAddress(String? address) =>
      state = state.copyWith(address: address);

  Future<void> saveOrg() async =>
      await ref.read(orgsDbProvider).upsertItem(state);
}
