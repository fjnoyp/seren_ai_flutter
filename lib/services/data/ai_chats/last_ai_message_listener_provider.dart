import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_ai_chat_messages_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_chat_thread_provider.dart';
import 'dart:async';

final lastAiMessageListenerProvider = NotifierProvider<LastAiMessageListenerNotifier, AiChatMessageModel?>(
  LastAiMessageListenerNotifier.new
);

class LastAiMessageListenerNotifier extends Notifier<AiChatMessageModel?> {
  Timer? _timer;

  @override
  AiChatMessageModel? build() {
    final curChatThread = ref.watch(curChatThreadProvider);
    
    if (curChatThread != null) {
      final chatThreadId = curChatThread.id;
      
      // Listen to the aiChatMessagesListenerFamProvider
      ref.listen(aiChatMessagesListenerFamProvider(chatThreadId), (previous, next) {
        if (next != null && next.isNotEmpty) {
          final lastMessage = next.last;
          if (lastMessage.type == AiChatMessageType.ai) {
            state = lastMessage;
            _startTimer();
          }
        }
      });
    }

    ref.onDispose(() => _timer?.cancel());

    return null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      state = null;
    });
  }
}
