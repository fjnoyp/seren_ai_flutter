import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_chat_messages_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'dart:async';

final lastAiMessageListenerProvider = NotifierProvider<LastAiMessageListenerNotifier, AiChatMessageModel?>(
  LastAiMessageListenerNotifier.new
);

class LastAiMessageListenerNotifier extends Notifier<AiChatMessageModel?> {
  Timer? _timer;

  @override
  AiChatMessageModel? build() {
    // Listen to the curUserChatMessagesListenerProvider
    ref.listen(curUserChatMessagesListenerProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        final lastMessage = next.first;
        if (lastMessage.type == AiChatMessageType.ai || lastMessage.type == AiChatMessageType.tool) {
          state = lastMessage;
          _startTimer();
        }
      }
    });

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