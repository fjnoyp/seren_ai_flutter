import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/cur_user_org_id_provider.dart';

final curUserAiChatThreadListenerProvider =
    NotifierProvider<CurUserAiChatThreadListenerNotifier, AiChatThreadModel?>(
        CurUserAiChatThreadListenerNotifier.new);

class CurUserAiChatThreadListenerNotifier extends Notifier<AiChatThreadModel?> {
  @override
  AiChatThreadModel? build() {
    final curAuthUserState = ref.read(curAuthStateProvider);
    final watchedCurAuthUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    final watchedCurOrgId = ref.watch(curUserOrgIdProvider);

    if (watchedCurAuthUser == null || watchedCurOrgId == null) {
      return null;
    }

    // Read in the thread 
    final db = ref.read(dbProvider);

    final getUserChatThreadQuery = '''
    SELECT *
    FROM ai_chat_threads
    WHERE author_user_id = '${watchedCurAuthUser.id}'
    AND parent_org_id = '${watchedCurOrgId}'
    LIMIT 1;
    ''';

    db.watch(getUserChatThreadQuery).listen((results) {
      if(results.isNotEmpty) {
        state = AiChatThreadModel.fromJson(results.first);
      } else {
        state = null;
      }
    });

    return null; 
  }
}