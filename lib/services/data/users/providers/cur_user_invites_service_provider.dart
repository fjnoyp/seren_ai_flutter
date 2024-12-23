import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/users/invites_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_invites_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curUserInvitesServiceProvider =
    NotifierProvider<CurUserInvitesService, List<InviteModel>>(
        () => CurUserInvitesService());

class CurUserInvitesService extends Notifier<List<InviteModel>> {
  @override
  List<InviteModel> build() {
    final userEmail = ref.watch(curUserProvider).valueOrNull?.email ?? '';
    ref
        .read(userInvitesRepositoryProvider)
        .watchPendingInvitesByEmail(userEmail: userEmail)
        .listen((pendingInvites) {
      state = pendingInvites;
    });

    return [];
  }

  Future<void> acceptInvite(InviteModel invite) async {
    await Supabase.instance.client.rpc(
      'accept_invite',
      params: {'invite_id_param': invite.id},
    );
  }

  Future<void> declineInvite(InviteModel invite) async {
    await ref.read(invitesDbProvider).updateItem(
        invite.copyWith(status: InviteStatus.declined));
  }
}
