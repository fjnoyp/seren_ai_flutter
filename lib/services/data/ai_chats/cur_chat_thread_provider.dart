import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_thread_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_threads_listener_provider.dart';

// TODO p3: provide different chat thread than the first ... TBD 
final curChatThreadProvider = Provider<AiChatThreadModel?>((ref) {
  final chatThreads = ref.watch(curUserAiChatThreadsListenerProvider);
  return chatThreads?.isNotEmpty == true ? chatThreads!.first : null;
});
