import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_tool_response_executor.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/cur_user_chat_messages_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'dart:async';

// Common type for all ai results to show 
// ie: ai chat messages and tool responses
class AiResult {} 

final lastAiMessageListenerProvider = NotifierProvider<LastAiMessageListenerNotifier, List<AiResult>>(
  LastAiMessageListenerNotifier.new
);

class LastAiMessageListenerNotifier extends Notifier<List<AiResult>> {
  Timer? _timer;

  @override
  List<AiResult> build() {
    // Listen to the curUserChatMessagesListenerProvider
    ref.listen(curUserChatMessagesListenerProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        final lastMessage = next.first;
        if (lastMessage.type == AiChatMessageType.ai) {
          state = List.from([lastMessage]);

          // base on message length determine timeout seconds 
          final timeoutSeconds = (lastMessage.content.length ~/ 10).clamp(3, double.infinity).toInt();
          _startTimer(seconds: timeoutSeconds);
        }
      }
    });

    ref.onDispose(() => _timer?.cancel());

    return [];
  }

  void addLastToolResponseResult(ToolResponseResult result) {
    // If there are existing results, add the new one

      state = List.from(state)..add(result);

    
    // For ToolResponseResult, use content length for timeout if available
    final timeoutSeconds = result.message.isNotEmpty
        ? (result.message.length ~/ 10).clamp(3, double.infinity).toInt()
        : 5;
    
    _startTimer(seconds: 10);
  }

  void _startTimer({int seconds = 5}) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), () {
      state = [];
    });
  }
}