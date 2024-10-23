import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_thread_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';

final curUserChatMessagesListenerProvider =
    NotifierProvider<CurUserChatMessagesListenerNotifier, List<AiChatMessageModel>?>(
        CurUserChatMessagesListenerNotifier.new);

class CurUserChatMessagesListenerNotifier extends Notifier<List<AiChatMessageModel>?> {
  @override
  List<AiChatMessageModel>? build() {
    
    final curUserChatThread = ref.watch(curUserAiChatThreadListenerProvider);

    if (curUserChatThread == null) {
      return null;
    }
    // Get the messages of the current user's chat thread
    final db = ref.read(dbProvider);

    final query = '''
    SELECT *
    FROM ai_chat_messages
    WHERE parent_chat_thread_id = '${curUserChatThread.id}'
    ORDER BY created_at DESC;
    ''';

    final subscription = db.watch(query).listen((results) {
      List<AiChatMessageModel> items =
          results.map((e) => AiChatMessageModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return [];
  }
}