import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/providers/cur_user_ai_chat_messages_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/messages/message_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';

class ChatMessagesDisplay extends ConsumerWidget {
  const ChatMessagesDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserAiChatMessagesProvider),
      data: (chatMessages) {
        return chatMessages.isEmpty
            ? const Text('No messages available')
            : ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) =>
                    AiChatMessageWidget(message: chatMessages[index]),
                reverse: true,
              );
      },
    );
  }
}
