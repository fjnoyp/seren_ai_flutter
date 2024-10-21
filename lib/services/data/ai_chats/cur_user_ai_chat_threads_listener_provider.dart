import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';

// Provide all chat threads for current user
final curUserAiChatThreadsListenerProvider = NotifierProvider<
    CurUserAiChatThreadsListenerNotifier,
    List<AiChatThreadModel>?>(CurUserAiChatThreadsListenerNotifier.new);

/// Get the current user's chat threads
class CurUserAiChatThreadsListenerNotifier
    extends Notifier<List<AiChatThreadModel>?> {
  @override
  List<AiChatThreadModel>? build() {
    final curAuthUserState = ref.watch(curAuthStateProvider);
    final watchedCurAuthUser = switch (curAuthUserState) {
      LoggedInAuthState() => curAuthUserState.user,
      _ => null,
    };

    if (watchedCurAuthUser == null) {
      return null;
    }

    final db = ref.read(dbProvider);

    // Get all chat threads which user is the author of
    final query = '''
    SELECT *
    FROM ai_chat_threads
    WHERE author_user_id = '${watchedCurAuthUser.id}'; 
    ''';

    final subscription = db.watch(query).listen((results) {
      List<AiChatThreadModel> items =
          results.map((e) => AiChatThreadModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
