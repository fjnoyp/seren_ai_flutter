import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/org_invites_repository.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';

final curOrgPendingInvitesProvider = StreamProvider<List<InviteModel>>((ref) {
  final orgId = ref.watch(curSelectedOrgIdNotifierProvider);
  if (orgId == null) return const Stream.empty();
  log('curOrgPendingInvitesProvider called with orgId: $orgId');
  return ref
      .watch(orgInvitesRepositoryProvider)
      .watchPendingInvitesByOrg(orgId: orgId);
});
