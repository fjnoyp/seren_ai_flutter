import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_ai_chat_thread_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/repositories/ai_chat_messages_repository.dart';

final curUserAiChatMessagesProvider =
    StreamProvider.autoDispose<List<AiChatMessageModel>>((ref) {
  return CurAiChatThreadDependencyProvider.watchStream(
    ref: ref,
    builder: (aiChatThread) {
      return ref
          .watch(aiChatMessagesRepositoryProvider)
          .watchThreadMessages(threadId: aiChatThread?.id ?? '');
    },
  );
});
