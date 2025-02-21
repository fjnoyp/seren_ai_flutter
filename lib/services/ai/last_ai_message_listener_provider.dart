import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'dart:async';

final lastAiMessageListenerProvider = NotifierProvider<LastAiMessageListenerNotifier, List<AiChatMessageModel>>(
  LastAiMessageListenerNotifier.new
);

class LastAiMessageListenerNotifier extends Notifier<List<AiChatMessageModel>> {
  Timer? _timer;

  @override
  List<AiChatMessageModel> build() {
    // Listen to the curUserChatMessagesListenerProvider
    // ref.listen(curUserChatMessagesListenerProvider, (previous, next) {
    //   if (next != null && next.isNotEmpty) {
    //     final lastMessage = next.first;
    //     if (lastMessage.type == AiChatMessageType.ai) {
    //       state = List.from([lastMessage]);

    //       // base on message length determine timeout seconds 
    //       final timeoutSeconds = (lastMessage.content.length ~/ 10).clamp(3, double.infinity).toInt();
    //       _startTimer(seconds: timeoutSeconds);
    //     }
    //   }
    // });

    ref.onDispose(() => _timer?.cancel());

    return [];
  }

  void addAiChatMessage(AiChatMessageModel message) {
    state = List.from(state)..add(message);
    _timer?.cancel();

    // For ToolResponseResult, use content length for timeout if available
    final timeoutSeconds = message.content.isNotEmpty
        ? (message.content.length ~/ 10).clamp(5, double.infinity).toInt()
        : 5;
    
    _startTimer(seconds: timeoutSeconds);
  }

  // void addLastToolResponseResult(AiRequestResultModel result) {
  //   // If there are existing results, add the new one

  //     state = List.from(state)..add(result);

  //   _timer?.cancel();
    
  //   // For ToolResponseResult, use content length for timeout if available
  //   final timeoutSeconds = result.resultForAi.isNotEmpty
  //       ? (result.resultForAi.length ~/ 10).clamp(5, double.infinity).toInt()
  //       : 5;
    
  //   _startTimer(seconds: timeoutSeconds);
  // }

  void clearState() {
    state = [];
    _timer?.cancel();
  }

  void _startTimer({int seconds = 5}) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), () {
      state = [];
    });
  }
}