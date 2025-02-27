import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/repositories/orgs_repository.dart';
import 'package:seren_ai_flutter/services/notifications/user_invite_notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final orgInviteServiceProvider = Provider((ref) => OrgInviteService(ref));

class OrgInviteService {
  final Ref ref;

  OrgInviteService(this.ref);

  Future<void> inviteUser(String orgId, String email, OrgRole role) async {
    final user = ref.read(curUserProvider).value;
    await Supabase.instance.client.rpc('invite_user', params: {
      'p_email': email,
      'p_org_id': orgId,
      'p_role': role.name,
      'p_author_user_id': user!.id,
    });

    // This exception should never happen, since users can only be invited to existing organizations.
    final org = await ref.read(orgsRepositoryProvider).getById(orgId);
    if (org == null) {
      log.severe(
          'Organization not found for orgId: $orgId. Cannot send invite notification.');
      return;
    }

    await ref.read(userInviteNotificationServiceProvider).handleNewInvite(
          orgId: orgId,
          orgName: org.name,
          invitedUserEmail: email,
          role: role,
          authorUserName: user.firstName,
        );
  }
}
