import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final orgInviteServiceProvider = Provider((ref) => OrgInviteService(ref));

class OrgInviteService {
  final Ref ref;

  OrgInviteService(this.ref);

  Future<void> inviteUser(String orgId, String email, OrgRole role) async {
    final user = ref.read(curUserProvider).value;
    final response = await Supabase.instance.client.rpc('invite_user', params: {
      'p_email': email,
      'p_org_id': orgId,
      'p_role': role.name,
      'p_author_user_id': user!.id,
    });
    log('inviteUser called:\n\temail: $email\n\trole: $role\n\torgId: $orgId\nWith response:\n$response');
  }
}
