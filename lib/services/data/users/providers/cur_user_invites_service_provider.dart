import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/users/invites_db_provider.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/joined_invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/user_invites_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final curUserInvitesStateProvider = StreamProvider<List<InviteModel>>(
//   (ref) => CurAuthDependencyProvider.watchStream(
//       ref: ref,
//       builder: (userId) => ref
//           .read(invitesRepositoryProvider)
//           .watchPendingInvitesByEmail(userId: userId)),
// );

final curUserInvitesServiceProvider =
    NotifierProvider<CurUserInvitesService, List<JoinedInviteModel>>(
        () => CurUserInvitesService());

class CurUserInvitesService extends Notifier<List<JoinedInviteModel>> {
  @override
  List<JoinedInviteModel> build() {
    final userId = ref.watch(curUserProvider).valueOrNull?.id ?? '';
    ref
        .read(userInvitesRepositoryProvider)
        .watchPendingInvitesByEmail(userId: userId)
        .listen((pendingInvites) {
      state = pendingInvites;
    });

    return [];
  }

  Future<void> acceptInvite(JoinedInviteModel joinedInvite) async {
    await Supabase.instance.client.rpc(
      'accept_invite',
      params: {'invite_id_param': joinedInvite.invite.id},
    );
  }

  Future<void> declineInvite(JoinedInviteModel joinedInvite) async {
    await ref.read(invitesDbProvider).updateItem(
        joinedInvite.invite.copyWith(status: InviteStatus.declined));
  }
}
