import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';

final curUserAiChatMessagesListenerProvider = NotifierProvider.family<CurUserAiChatMessagesListenerNotifier, List<AiChatMessageModel>?, String>(
  CurUserAiChatMessagesListenerNotifier.new
);

class CurUserAiChatMessagesListenerNotifier extends FamilyNotifier<List<AiChatMessageModel>?, String> {
  @override
  List<AiChatMessageModel>? build(String arg) {
    final chatThreadId = arg;
    
    final db = ref.read(dbProvider);
    final curUser = ref.read(curAuthUserProvider);

    if (curUser == null) return null;

    final query = '''
      SELECT * 
      FROM ai_chat_messages
      WHERE parent_chat_thread_id = '$chatThreadId'
      ORDER BY created_at ASC
    ''';

    final subscription = db.watch(query).listen((results) {
      List<AiChatMessageModel> messages = results.map((e) => AiChatMessageModel.fromJson(e)).toList();
      state = messages;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
